from python_on_whales import DockerClient

name = "fox"

InputDataName = name
SaveVideoName = name
SaveMeshName = name

with open("./docker-compose.yml","r") as f:
    template = f.read()
    print(template)
    template = template.format(InputDataName,SaveMeshName,SaveVideoName)
with open("{}.yml".format(name),"w") as f:
    f.write(template)
docker = DockerClient(compose_files=["{}.yml".format(name)])
docker.compose.build()
docker.compose.up()
docker.compose.down()


print("All Settled")
#docker.compose.create(services=["instant-ngp"])
#docker.compose.up(services="instant-ngp",detach=True)
#output = docker.compose.run(service="instant-ngp",command=[r"python3 /opt/instant-ngp/scripts/run.py --scene /volume/input/fox --save_mesh /volume/output/fox.obj"], remove=True,tty=False,detach=False,stream=True)
#for stream_type, stream_content in output:
    #if stream_type == 'stdout':
 #   print(stream_content.decode('utf-8'))
#docker.compose.up()
#docker.compose.down()
