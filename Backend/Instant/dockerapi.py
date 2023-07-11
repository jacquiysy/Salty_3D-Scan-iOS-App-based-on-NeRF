import docker
client = docker.from_env()
images = client.images.list()
print(images[0])
img = images[0]
container = client.containers.run(img, "python3 /opt/instant-ngp/scripts/run.py --scene /opt/instant-ngp/data/nerf/fox --save_mesh /volume/fox.obj", auto_remove=True,detach=True,environment=["NVIDIA_DRIVER_CAPABILITIES=compute,utility,graphics","DISPLAY=$DISPLAY",volumes=['/data/3DScan/Instant/:/volume'],working_dir="/opt/instant-ngp",)
