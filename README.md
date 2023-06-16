# Getting Started

## Python Dependencies
Run `pip install -r requirements.txt` to install the python packages.

Here are the list of packages:
`
commentjson
imageio
numpy
opencv-python-headless
pybind11
pyquaternion
scipy
rich
tqdm
ninja
torch
scipy
lpips
pandas
trimesh
PyMCubes
torch-ema
dearpygui
packaging
matplotlib
tensorboardX
opencv-python
imageio-ffmpeg
pymeshlab
torch-scatter
xatlas
scikit-learn
torchmetrics
`

## Unity for AR Placement
We will use [Unity](https://unity.com/) for AR placement 

# Model and Engine
## Story Map

![stroyMap](https://github.com/jacquiysy/Salty/assets/55369832/c62b8f6c-3b1f-4168-865d-2a0efeb6ba48)
| Component                | Description                              | Connection                               |
| ------------------------ | ---------------------------------------- | ---------------------------------------- |
| **Data Acquisition UI**  | Acquire data from various sources including users' phones. | Connect to**3D Generating Models** to transfer data and parameters using views. |
| **3D Generating Models** | Generate 3D models based on the data obtained and parameters users specified. | Connect to **Display UI** for 3D representation of generated models. |
| **Display UI**           | Display the generated 3D models to the user. | Connect to **Other App** to share 3D representation to other platforms and **Gallery** to save 3D representation on the cloud. |
| **Other App**            | Provide additional functionality extended from the app including sharing. | /                                        |
| **Gallery**              | Allow the user to view and manage a collection of 3D models. | Connect to **Other Users** allowing other users to download generated 3D representations. |
| **Other Users**          | Allow other users to interact with the app. | Connect to **Display UI** allowing other users to share models. |

## Block Diagram

![block_diagram](https://github.com/jacquiysy/Salty/assets/55369832/d6324b3a-b45b-4ccb-adb0-56bfc54ce2fd)
### Data Acquisition UI
Use ARKit offered by swift, which contains a rendering function. Then Use camera position and implement camera calibration algorithm to compute intrinsic and extrinsic matrices. Maybe cameraCalibrationData function can be directly applied to photos. Use extrinsic matrices to calculate the world coordinates. Use the world coordinates of cameras and objects, compute missing parts and give a camera movement and rotation suggestion. When the user begin to take the picture, we are able to give a real-time suggestion of whether this pose is appropriate or not by the estimated coordinate and the previous images.


### 3D Generating Models
We utilize the taken image and the Nerf algorithm to train a MLP model, which should contain the 3D information. By quering from different pose, he output will be a Nerf-based MLP parameter, which could be considered as a compressed version of the 3D model. The generated MLP parameter could be generated to other popular 3D representation format, such as the Mesh format, using Nerf2Mesh algorithm.

Ref: Instant Nerf: https://github.com/NVlabs/instant-ngp
Ref: Nerf2Mesh: https://github.com/ashawkey/nerf2mesh

### Display UI
In the first part, we would like to use swift to display the .obj model, which is in the mesh format. We will directly utilizing the Swift's scene-related API. For AR placement, we would like to work on Unity's AR foundation system and export the app as Swift, which could be easily combined with our main UI. An alternative way is to directly export the python model in to Unity.

Ref: Display .obj: https://developer.apple.com/forums/thread/3979
Ref: AR placement: https://github.com/fariazz/ARFoundationPlacementIndicator
Ref: NeRF model to Unity: https://github.com/julienkay/MobileNeRF-Unity-Viewer

### Other App
We utilize system APIs such as iOS APIs to provide additional functionality to the user. One way to share the result with other apps is by using the Web Share API Level 2. This API allows for sharing files, including images, from a web app running in Safari on iOS. 

Ref: iOS Safari Web Share API Level 2: https://developer.apple.com/forums/thread/133310

### Gallery
We use a backend database to allow interaction with users. The backend server will be built using Python and a web framework such as Django. Django provides functionalities for uploading and downloading files through the use of APIs that enable communication between the frontend of the app and the backend database.

Ref: File Uploads: https://docs.djangoproject.com/en/4.2/topics/http/file-uploads/
# APIs and Controller
### User login interface
**Web Authentication API**

WebAuthn uses asymmetric (public-key) cryptography instead of passwords or SMS texts for registering, authenticating, and multi-factor authentication with websites.

**Returns**

| Key | Location | Type | Description |
| --- | --- | --- | --- |
|`timeout` | JSON | number | time used in ms |
|`success` | JSON | function | function of succeed in login the interface|
|`fail` | JSON | function | function of fail to login the interface | 
|`complete` | JSON | function | function of finish the login process |

**`object.success` function**
| Location | Type | Description |
| --- | --- | --- |
| code | string | openid, session key and other login information|

**`object.fail` function**
| Location | Type | Description |
| --- | --- | --- |
|errMsg | string | error message |
| errno | number | errno code|


### File upload and sharing
**Filestack**

**Request Parameters**

| Key | Location | Type | Description |
| --- | --- | --- | --- |
|`--data-binary` | string | @file name | name of the file for uploading|
|`--header` | string | Content-Type | image/png for image uploading|

**Returns**
| Key | Location | Type | Description |
| --- | --- | --- | --- |
|`url` | JSON | string | location of file being stored|
|`size` | JSON | int | size of file in KB |
|`type` | JSON | string | same as header in `REQUEST`|
|`filename`| JSON | string | name of the file for uploading|
|`key` | JSON | string | file name in the cloud database |

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
