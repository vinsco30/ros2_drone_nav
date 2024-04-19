#TF bridge for ROS2

import os

from ament_index_python.packages import get_package_share_directory

from launch import LaunchDescription
from launch.actions import ExecuteProcess
from launch.conditions import IfCondition
from launch.substitutions import LaunchConfiguration
from launch.launch_description_sources import PythonLaunchDescriptionSource
from launch.actions import IncludeLaunchDescription
from launch.actions import DeclareLaunchArgument

from launch_ros.actions import Node

def generate_launch_description():

    pkg_ros_gz_sim_demos = get_package_share_directory('ros_gz_sim_demos')

    # RViz
    rviz = Node(
        package='rviz2',
        executable='rviz2',
        arguments=[
            '-d', os.path.join(pkg_ros_gz_sim_demos, 'rviz', 'tf_bridge.rviz')
        ],
        condition=IfCondition(LaunchConfiguration('rviz'))
    )

    # TF bridge
    tf_bridge = Node(
        package='ros_gz_bridge',
        executable='parameter_bridge',
        arguments=[
            '/world/default/model/base_link/joint_state@'
            'sensor_msgs/msg/JointState[gz.msgs.Model',
            '/model/base_link/pose@'
            'tf2_msgs/msg/TFMessage[gz.msgs.Pose_V'
        ],
        output='screen',
        remappings=[
            ('/model/base_link/pose', '/tf'),
            ('/world/default/model/base_link/joint_state', '/joint_states')
        ]
    )
    
    return LaunchDescription([
        DeclareLaunchArgument('rviz', default_value='true',
                              description='Open RViz. '),
        
        tf_bridge,
        rviz,
    ])

