# Getting Started

# Model and Engine
## Story Map

![stroyMap](https://github.com/jacquiysy/Salty/assets/55369832/c62b8f6c-3b1f-4168-865d-2a0efeb6ba48)


## Block Diagram

![block_diagram](https://github.com/jacquiysy/Salty/assets/55369832/d6324b3a-b45b-4ccb-adb0-56bfc54ce2fd)
### Data Acquisition UI
**How the functionalities are implemented?**
Use ARKit offered by swift, which contains a rendering function. Then Use camera position and implement camera calibration algorithm to compute intrinsic and extrinsic matrices. Maybe cameraCalibrationData function can be directly applied to photos. Use extrinsic matrices to calculate the world coordinates. Use the world coordinates of cameras and objects, compute missing parts and give a camera movement and rotation suggestion. When the user begin to take the picture, we are able to give a real-time suggestion of whether this pose is appropriate or not by the estimated coordinate and the previous images.

Ref: Camera 

### 3D Generating Models
**How the functionalities are implemented?**
We utilize the taken image and the Nerf algorithm to train a MLP model, which should contain the 3D information. By quering from different pose, he output will be a Nerf-based MLP parameter, which could be considered as a compressed version of the 3D model. The generated MLP parameter could be generated to other popular 3D representation format, such as the Mesh format, using Nerf2Mesh algorithm.

Ref: Instant Nerf: https://github.com/NVlabs/instant-ngp
Ref: Nerf2Mesh: https://github.com/ashawkey/nerf2mesh

### Display UI
**How the functionalities are implemented?**
In the first part, we would like to use swift to display the .obj model, which is in the mesh format. We will directly utilizing the Swift's scene-related API. For AR placement, we would like to work on Unity's AR foundation system and export the app as Swift, which could be easily combined with our main UI.

Ref: Display .obj: https://developer.apple.com/forums/thread/3979
Ref: AR placement: https://github.com/fariazz/ARFoundationPlacementIndicator

### Other App
**How the functionalities are implemented?**

### Gallery
**How the functionalities are implemented?**

### Other user
**How the functionalities are implemented?**
# APIs and Controller

# View UI/UX

# Team Roster
| Team Member       | Contribution  |
| ------------------------ | ------------------ |
| Zihao Wei |      |
| Zixuan Pan |     |
| Shuyuan Yang |     | 
| Guanhua Xue |      | 
| Chenhao Zheng |          |
| Yihan Jin |        |
