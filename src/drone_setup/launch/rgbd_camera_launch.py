#Luanch file for drone RGBD sensor

import os

from ament_index_python.packages import get_package_share_directory

from launch import LaunchDescription
from launch.actions import DeclareLaunchArgument
from launch.actions import IncludeLaunchDescription
from launch.conditions import IfCondition
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.substitutions import LaunchConfiguration

from launch_ros.actions import Node

def generate_launch_description():

    pkg_ros_gz_sim_demos = get_package_share_directory('ros_gz_sim_demos')

    # RViz
    rviz = Node(
        package='rviz2',
        executable='rviz2',
        arguments=[
            '-d', os.path.join(pkg_ros_gz_sim_demos, 'rviz', 'rgbd_camera_bridge.rviz')
        ],
        condition=IfCondition(LaunchConfiguration('rviz'))
    )

    remappings = [('/camera', '/camera/image'),
                  ('/camera_info', '/camera/camera_info')]
    # Bridge
    bridge = Node(
        package='ros_gz_bridge',
        executable='parameter_bridge',
        arguments=[
            '/camera@sensor_msgs/msg/Image@gz.msgs.Image',
            '/camera_info@sensor_msgs/msg/CameraInfo@gz.msgs.CameraInfo',
            '/rgbd_camera/image@sensor_msgs/msg/Image@gz.msgs.Image',
            '/rgbd_camera/camera_info@sensor_msgs/msg/CameraInfo@gz.msgs.CameraInfo',
            '/rgbd_camera/depth_image@sensor_msgs/msg/Image@gz.msgs.Image',
            '/rgbd_camera/points@sensor_msgs/msg/PointCloud2@gz.msgs.PointCloudPacked'
        ],
        output='screen',
        remappings=remappings,
    )

    return LaunchDescription([
        DeclareLaunchArgument('rviz', default_value='true',
                              description='Open RViz. '),
        
        bridge,
        rviz,
    ])

