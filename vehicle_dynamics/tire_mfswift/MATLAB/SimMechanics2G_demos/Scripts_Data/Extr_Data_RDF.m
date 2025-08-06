road_raw = importdata('TNO_PolylineRoad.rdf',' ');
road.x = road_raw.data(2:end-1,1);
road.zl = road_raw.data(2:end-1,2);
road.zr = road_raw.data(2:end-1,3);

Road_Extr_Data_L = flipud([road.x road.zl;flipud(road.x) flipud(road.zl)-0.1]);
Road_Extr_Data_R = flipud([road.x road.zr;flipud(road.x) flipud(road.zr)-0.1]);
%Road_Extr_Data_L = [road.x road.zl];

%figure
%plot(Road_Extr_Data_L(:,1),Road_Extr_Data_L(:,2))
