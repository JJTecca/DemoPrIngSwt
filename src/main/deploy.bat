@echo off
echo reset domain
./asadmin stop-domain
echo starting domain
./asadmin start-domain
./asadmin undeploy ParkingLot-1.0-SNAPSHOT
echo starting deployment
./asadmin deploy D:\Laburi_IngSw\ParkingLot\build\libs\ParkingLot-1.0-SNAPSHOT.war  
pause
