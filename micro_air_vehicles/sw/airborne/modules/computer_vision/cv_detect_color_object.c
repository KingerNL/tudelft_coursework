// green attractor color detection implementation

// This module implements green object detection using color filtering by analyzing
// the camera input to identify green regions, segments the image, counts green pixels,
// and communicates detection data for control.

#include "modules/computer_vision/cv_detect_color_object.h"
#include "modules/computer_vision/cv.h"
#include "modules/core/abi.h"
#include <stdbool.h>
#include "pthread.h"
#include <stdlib.h>
#include <stdio.h>
#include <math.h>
#include "std.h"

#define PRINT(string,...) fprintf(stderr, "[object_detector->%s()] " string,__FUNCTION__ , ##__VA_ARGS__)
#if OBJECT_DETECTOR_VERBOSE
#define VERBOSE_PRINT PRINT
#else
#define VERBOSE_PRINT(...)
#endif

static pthread_mutex_t mutex;

#ifndef COLOR_OBJECT_DETECTOR_FPS1
#define COLOR_OBJECT_DETECTOR_FPS1 0 ///< Default FPS (zero means run at camera fps)
#endif
#ifndef COLOR_OBJECT_DETECTOR_FPS2
#define COLOR_OBJECT_DETECTOR_FPS2 0 ///< Default FPS (zero means run at camera fps)
#endif

// stadard filter settings for inside paparazzi
uint8_t cod_lum_min1 = 0;
uint8_t cod_lum_max1 = 0;
uint8_t cod_cb_min1 = 0;
uint8_t cod_cb_max1 = 0;
uint8_t cod_cr_min1 = 0;
uint8_t cod_cr_max1 = 0;

uint8_t cod_lum_min2 = 0;
uint8_t cod_lum_max2 = 0;
uint8_t cod_cb_min2 = 0;
uint8_t cod_cb_max2 = 0;
uint8_t cod_cr_min2 = 0;
uint8_t cod_cr_max2 = 0;


// standard filter settings for outside paparazzi
bool cod_draw1 = false;       // drawing on the image for visualization
bool cod_draw2 = false;       

uint16_t num_segments = 5;    // the number of segments we want to divide the image into
uint8_t fill_y_limit = 128;   // the y limit for the carpet fill, this is the line where we stop counting pixels

// define global variables which will be send over via ABI
struct color_object_t {
  int32_t x_c;
  int32_t y_c;
  int32_t color_count;
  bool updated;
  int32_t segment_counts[5]; // pre-allocated array for segment counts
};

struct color_object_t global_filters[2];

#define STACK_MAX 1024

// function declaration
struct image_t *object_detector1(struct image_t *img, uint8_t camera_id);
struct image_t *object_detector2(struct image_t *img, uint8_t camera_id);

// functions for drawing lines on the image for visualization
void draw_vertical_line(struct image_t *img, int x, int y);
void draw_horizontal_line(struct image_t *img, int x);

bool is_pixel_green(uint8_t *buffer, int x, int y, int width,
  uint8_t lum_min, uint8_t lum_max,
  uint8_t cb_min, uint8_t cb_max,
  uint8_t cr_min, uint8_t cr_max);

bool is_pixel_solid_green(uint8_t *buffer, int x, int y, int width, int height,
  uint8_t lum_min, uint8_t lum_max,
  uint8_t cb_min, uint8_t cb_max,
  uint8_t cr_min, uint8_t cr_max);
  
uint32_t count_green_pixels(struct image_t *img, bool draw, 
                              int *segment_counts, int num_segments,
                              uint8_t lum_min, uint8_t lum_max,
                              uint8_t cb_min, uint8_t cb_max,
                              uint8_t cr_min, uint8_t cr_max, uint8_t fill_y_limit);

/*
 * object_detector
 * @param img - input image to process
 * @param filter - which detection filter to process
 * @return img
 */
static struct image_t *object_detector(struct image_t *img, uint8_t filter)
{
  uint8_t lum_min, lum_max;
  uint8_t cb_min, cb_max;
  uint8_t cr_min, cr_max;
  bool draw;

  switch (filter){
    case 1:
      lum_min = cod_lum_min1;
      lum_max = cod_lum_max1;
      cb_min = cod_cb_min1;
      cb_max = cod_cb_max1;
      cr_min = cod_cr_min1;
      cr_max = cod_cr_max1;
      draw = cod_draw1;
      break;
    case 2:
      lum_min = cod_lum_min2;
      lum_max = cod_lum_max2;
      cb_min = cod_cb_min2;
      cb_max = cod_cb_max2;
      cr_min = cod_cr_min2;
      cr_max = cod_cr_max2;
      draw = cod_draw2;
      break;
    default:
      return img;
  };

  int segment_counts[num_segments];

  for (uint16_t i = 0; i < num_segments; i++) {
    segment_counts[i] = 0;
  }
  
  int32_t count = count_green_pixels(img, draw, segment_counts, num_segments, lum_min, lum_max, cb_min, cb_max, cr_min, cr_max,fill_y_limit);

  
  // calculate the percentage of green in every segment
  for (uint16_t i = 0; i < num_segments; i++) {
    segment_counts[i] = (segment_counts[i] * 100) / (img->w * (img->h / num_segments));
  }

  // Update global filter data
  pthread_mutex_lock(&mutex);
  global_filters[filter-1].color_count = count;
  global_filters[filter-1].updated = true;
  for (uint16_t i = 0; i < 5; i++) {
    global_filters[filter-1].segment_counts[i] = segment_counts[i];
  }
  pthread_mutex_unlock(&mutex);

  return img;
}

struct image_t *object_detector1(struct image_t *img, uint8_t camera_id __attribute__((unused)))
{
  return object_detector(img, 1);
}

struct image_t *object_detector2(struct image_t *img, uint8_t camera_id __attribute__((unused)))
{
  return object_detector(img, 2);
}

// function to initialize the color object detector
void color_object_detector_init(void)
{
  memset(global_filters, 0, 2*sizeof(struct color_object_t));
  pthread_mutex_init(&mutex, NULL);
  #ifdef COLOR_OBJECT_DETECTOR_CAMERA1
  #ifdef COLOR_OBJECT_DETECTOR_LUM_MIN1
    cod_lum_min1 = COLOR_OBJECT_DETECTOR_LUM_MIN1;
    cod_lum_max1 = COLOR_OBJECT_DETECTOR_LUM_MAX1;
    cod_cb_min1 = COLOR_OBJECT_DETECTOR_CB_MIN1;
    cod_cb_max1 = COLOR_OBJECT_DETECTOR_CB_MAX1;
    cod_cr_min1 = COLOR_OBJECT_DETECTOR_CR_MIN1;
    cod_cr_max1 = COLOR_OBJECT_DETECTOR_CR_MAX1;
  #endif
  #ifdef COLOR_OBJECT_DETECTOR_DRAW1
    cod_draw1 = COLOR_OBJECT_DETECTOR_DRAW1;
  #endif

    cv_add_to_device(&COLOR_OBJECT_DETECTOR_CAMERA1, object_detector1, COLOR_OBJECT_DETECTOR_FPS1, 0);
  #endif

  #ifdef COLOR_OBJECT_DETECTOR_CAMERA2
  #ifdef COLOR_OBJECT_DETECTOR_LUM_MIN2
    cod_lum_min2 = COLOR_OBJECT_DETECTOR_LUM_MIN2;
    cod_lum_max2 = COLOR_OBJECT_DETECTOR_LUM_MAX2;
    cod_cb_min2 = COLOR_OBJECT_DETECTOR_CB_MIN2;
    cod_cb_max2 = COLOR_OBJECT_DETECTOR_CB_MAX2;
    cod_cr_min2 = COLOR_OBJECT_DETECTOR_CR_MIN2;
    cod_cr_max2 = COLOR_OBJECT_DETECTOR_CR_MAX2;
  #endif
  #ifdef COLOR_OBJECT_DETECTOR_DRAW2
    cod_draw2 = COLOR_OBJECT_DETECTOR_DRAW2;
  #endif

    cv_add_to_device(&COLOR_OBJECT_DETECTOR_CAMERA2, object_detector2, COLOR_OBJECT_DETECTOR_FPS2, 1);
  #endif
}

//function checks if a pixel is within the specified color bounds
bool is_pixel_green(uint8_t *buffer, int x, int y, int width,
                    uint8_t lum_min, uint8_t lum_max,
                    uint8_t cb_min, uint8_t cb_max,
                    uint8_t cr_min, uint8_t cr_max) {
    uint8_t *yp, *up, *vp;

    if (x % 2 == 0) {
        up = &buffer[y * 2 * width + 2 * x];
        yp = &buffer[y * 2 * width + 2 * x + 1];
        vp = &buffer[y * 2 * width + 2 * x + 2];
    } else {
        up = &buffer[y * 2 * width + 2 * x - 2];
        vp = &buffer[y * 2 * width + 2 * x];
        yp = &buffer[y * 2 * width + 2 * x + 1];
    }

    return (*yp >= lum_min) && (*yp <= lum_max) &&
           (*up >= cb_min) && (*up <= cb_max) &&
           (*vp >= cr_min) && (*vp <= cr_max);
}

//function checks if the neighbouring pixels are also green 
//(get ride of noise, note increase x/y search window for stricter filtering)
bool is_pixel_solid_green(uint8_t *buffer, int x, int y, int width, int height,
                          uint8_t lum_min, uint8_t lum_max,
                          uint8_t cb_min, uint8_t cb_max,
                          uint8_t cr_min, uint8_t cr_max) {
    int matches = 0;
    int valid_neighbors = 0;

    int x_search_window = 5; //will look num/2 left and right relative to pixel
    int y_search_window = 5; //will look num/2 down and up relative to pixel

    int half_x = x_search_window / 2;
    int half_y = y_search_window / 2;

    for (int dy = -half_y; dy <= half_y; dy++) {
        for (int dx = -half_x; dx <= half_x; dx++) {
            if (dx == 0 && dy == 0) continue;

            int nx = x + dx;
            int ny = y + dy;

            if (nx >= 0 && nx < width && ny >= 0 && ny < height) {
                valid_neighbors++;
                if (is_pixel_green(buffer, nx, ny, width, lum_min, lum_max, cb_min, cb_max, cr_min, cr_max)) {
                    matches++;
                }
            }
        }
    }
    float percentage_required = 0.5f; // threshold percentage of search window
    int required_matches_threshold = (int)(percentage_required * valid_neighbors);

    return matches >= required_matches_threshold;
}

/*
 * count_green_pixels
 *
 * Also returns the amount of pixels that satisfy these filter bounds.
 *
 * @param img - input image to process formatted as YUV422.
 * @param lum_min - minimum Y value for the filter in YCbCr colorspace
 * @param lum_max - maximum Y value for the filter in YCbCr colorspace
 * @param cb_min - minimum Cb value for the filter in YCbCr colorspace
 * @param cb_max - maximum Cb value for the filter in YCbCr colorspace
 * @param cr_min - minimum Cr value for the filter in YCbCr colorspace
 * @param cr_max - maximum Cr value for the filter in YCbCr colorspace
 * @param draw - whether or not to draw on image
 * @param segment_counts - array to store the number of pixels in each segment
 * @param fill_y_limit - y limit for the carpet fill
 * @return number of pixels in the image within the filter bounds.
 */
uint32_t count_green_pixels(struct image_t *img, bool draw, 
                            int *segment_counts, int num_segments,
                            uint8_t lum_min, uint8_t lum_max,
                            uint8_t cb_min, uint8_t cb_max,
                            uint8_t cr_min, uint8_t cr_max,
                            uint8_t fill_y_limit)
{
  uint32_t cnt = 0;
  uint8_t *buffer = img->buf;

  int IMAGE_WIDTH = img->w;
  int IMAGE_HEIGHT = img->h;
  int LIMIT = (int) fill_y_limit;

  int segment_height = (IMAGE_HEIGHT + num_segments - 1) / num_segments;

  for (uint16_t y = 0; y < IMAGE_HEIGHT; y++) {
    bool detected_right = false;
    int segment_index = y / segment_height;

    // Upper bound for green pixel detection (not looking at the whole image otherwise set x = IMAGE_WIDTH)
    for (int x = 168; x >= 0; x--) {
      uint8_t *yp, *up, *vp;

      if (x % 2 == 0) {
        // Even x
        up = &buffer[y * 2 * IMAGE_WIDTH + 2 * x];       // U
        yp = &buffer[y * 2 * IMAGE_WIDTH + 2 * x + 1];   // Y1
        vp = &buffer[y * 2 * IMAGE_WIDTH + 2 * x + 2];   // V
      } else {
        // Odd x
        up = &buffer[y * 2 * IMAGE_WIDTH + 2 * x - 2];   // U (shared)
        vp = &buffer[y * 2 * IMAGE_WIDTH + 2 * x];       // V
        yp = &buffer[y * 2 * IMAGE_WIDTH + 2 * x + 1];   // Y2
      }

      bool is_color_match = is_pixel_green(buffer, x, y, IMAGE_WIDTH, lum_min, lum_max, cb_min, cb_max, cr_min, cr_max);
      bool is_neighbor_color = is_pixel_solid_green(buffer, x, y, IMAGE_WIDTH, IMAGE_HEIGHT, lum_min, lum_max, cb_min, cb_max, cr_min, cr_max);

      if (is_color_match && is_neighbor_color) {
          cnt++;
          segment_counts[segment_index]++;
          if (draw) {
            *yp = 255;
          }
          if (x < LIMIT) {
            detected_right = true;
          }
      }

      // Once green is detected in this row, make pixels to the left green and count in respective segment
      if (detected_right && !is_color_match) {
        cnt++;
        segment_counts[segment_index]++;
        if (draw) {
          *yp = 255;
          // *yp = 245;
          // *up = 96;
          // *vp = 130;
        }
      }
    }
  }
  // Debugging Visuals
  draw_vertical_line(img, 0, IMAGE_HEIGHT/5);
  draw_vertical_line(img, 0, IMAGE_HEIGHT*2/5);
  draw_vertical_line(img, 0, IMAGE_HEIGHT*3/5);
  draw_vertical_line(img, 0, IMAGE_HEIGHT*4/5);
  draw_horizontal_line(img, LIMIT); // Green pixel detection limit
  draw_horizontal_line(img, 168); // Carpet removal limit

  return cnt;
}



// send the color object detection data over ABI
void color_object_detector_periodic(void)
{
  static struct color_object_t local_filters[2];
  pthread_mutex_lock(&mutex);
  memcpy(local_filters, global_filters, 2*sizeof(struct color_object_t));
  pthread_mutex_unlock(&mutex);

  if (local_filters[0].updated) {
    // Send the VISUAL_DETECTION message (existing functionality)
    AbiSendMsgVISUAL_DETECTION(COLOR_OBJECT_DETECTION1_ID, local_filters[0].x_c, local_filters[0].y_c,
                               0, 0, local_filters[0].color_count, 0);

    // Send the SEGMENT_COUNTS message for filter 1
    AbiSendMsgSEGMENT_COUNTS(GREEN_DETECTOR_SEGMENT_COUNTS_ID,
                              local_filters[0].segment_counts[0],
                              local_filters[0].segment_counts[1],
                              local_filters[0].segment_counts[2],
                              local_filters[0].segment_counts[3],
                              local_filters[0].segment_counts[4]);
    
    local_filters[0].updated = false;
  }

  if (local_filters[1].updated) {
    // Send the VISUAL_DETECTION message (existing functionality)
    printf("%d", local_filters[1].color_count);
    AbiSendMsgVISUAL_DETECTION(COLOR_OBJECT_DETECTION2_ID, local_filters[1].x_c, local_filters[1].y_c,
                                0, 0, local_filters[1].color_count, 1);

    // Send the SEGMENT_COUNTS message for filter 1
    AbiSendMsgSEGMENT_COUNTS(GREEN_DETECTOR_SEGMENT_COUNTS_ID,
                              local_filters[1].segment_counts[0],
                              local_filters[1].segment_counts[1],
                              local_filters[1].segment_counts[2],
                              local_filters[1].segment_counts[3],
                              local_filters[1].segment_counts[4]);

    local_filters[1].updated = false;
  }
}

// function to draw a vertical line on the image
void draw_vertical_line(struct image_t *img, int x, int y) {
  if (x < 0 || x >= img->w) return; // Bounds check

  uint8_t *buffer = img->buf;

  for (x;x < img->w; x++) {
      uint8_t *yp;
      if (x % 2 == 0) {
          // Even x, gets new U and V values
          yp = &buffer[y * 2 * img->w + 2 * x + 1];  // Y1
      } else {
          // Odd x, shares U and V with the previous pixel
          yp = &buffer[y * 2 * img->w + 2 * x + 1];  // Y2
      }
      *yp = 0;  // Darken pixel to lowest intensity (black)
  }
}


// Draws a horizontal line across the image at a given y-coordinate
void draw_horizontal_line(struct image_t *img, int x) {
  if (x < 0 || x >= img->h) return; // Bounds check

  uint8_t *buffer = img->buf;

  // Green Line
  for (int y = 0; y < img->h; y++) {
    int index = y * 2 * img->w + 2 * x;
    if (x % 2 == 0) {
      buffer[index + 1] = 0;
      buffer[index]     = 0;
      buffer[index + 2] = 0;
    } else {
      buffer[index + 1] = 0;
      buffer[index - 2] = 0;
      buffer[index]     = 0;
    }
  }
}
