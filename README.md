# ROS2 Drone Navigation 

To run the simulator with PX4 and the Tarot X500 model with depth camera run in a terminal:
```bash
cd ..
cd /home/dev/src/PX4-Autopilot
make px4_sitl gz_x500_depth
  ```
Then, in a second terminal run:
```bash
MicroXRCEAgent udp4 -p 8888
  ```
  