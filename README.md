# ROS2 Drone Navigation 

To run the simulator with PX4 and the Tarot X500 model with depth camera run in a terminal:
```bash
cd 
cd src/PX4-Autopilot
make px4_sitl gz_x500_depth
  ```
Then, in a second terminal run:
```bash
MicroXRCEAgent udp4 -p 8888
  ```

To activate the streaming through the `ros_gz_bridge` of the RGB-D sensor execute in another terminal the command:
```bash
ros2 launch drone_setup rgbd_camera_launch.py
  ```
