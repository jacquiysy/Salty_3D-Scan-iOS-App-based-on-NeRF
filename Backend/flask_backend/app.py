import os
from flask import Flask
from flask import render_template, flash, request, redirect, url_for, send_from_directory
from werkzeug.utils import secure_filename
from python_on_whales import DockerClient
import shutil
import zipfile
 


app = Flask(__name__)

UPLOAD_FOLDER = 'upload'
INPUT_FOLDER = 'input'
OUTPUT_FOLDER = 'output'
YML_FOLDER = 'ymls'

UPLOAD_PATH = os.path.join(app.root_path,UPLOAD_FOLDER)
INPUT_PATH = os.path.join(app.root_path,INPUT_FOLDER)
OUTPUT_PATH = os.path.join(app.root_path,OUTPUT_FOLDER)
YML_PATH = os.path.join(app.root_path,YML_FOLDER)

# ALLOWED_EXTENSIONS = {'zip'}

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['INPUT_FOLDER'] = INPUT_FOLDER
app.config['OUTPUT_FOLDER'] = OUTPUT_FOLDER
app.config['YML_FOLDER'] = YML_FOLDER
app.config['SESSION_TYPE'] = 'filesystem'
app.config['SECRET_KEY'] = os.urandom(24)

@app.route('/')
def index():
    return "hello world"

# def allowed_file(filename):
#     return '.' in filename and \
#            filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS

@app.route('/upload', methods=['GET','POST'])
def upload():
    if request.method == 'POST':
        if 'file' not in request.files:
            flash('No file part')
            return redirect(request.url)
        file = request.files['file']
        if file.filename == '':
            flash('No selected file')
            return redirect(request.url)
        else:
            filename = secure_filename(file.filename)
            file_path =os.path.join(app.config['UPLOAD_FOLDER'], filename)
            if os.path.exists(file_path):
                os.remove.rmtree(file_path)
            #print(save_path)
            file.save(file_path)
            return redirect(url_for('upload'))
    return "Uploaded"


def unzip_file(zip_src, dst_dir):
    r = zipfile.is_zipfile(zip_src)
    if r:     
        fz = zipfile.ZipFile(zip_src, 'r')
        for file in fz.namelist():
            fz.extract(file, dst_dir)
        return True       
    else:
        print('This is not zip')
        return False

@app.route('/launch/<filename>')
def launch(filename): 
    # Unzip from upload to input
    # input_dir=os.path.join(app.config['INPUT_FOLDER'], filename)
    input_dir = app.config["INPUT_FOLDER"]
    input_dir_file=os.path.join(app.config['INPUT_FOLDER'], filename)
    if filename[-3:] !="zip":
        filename_zip = filename + ".zip"

    zip_path = os.path.join(app.config["UPLOAD_FOLDER"],filename_zip)

    if os.path.exists(input_dir_file):
        shutil.rmtree(input_dir_file)

    #print(zip_path)
    #if not os.path.exists(zip_path):
    #    return "nofile"

    with zipfile.ZipFile(zip_path) as zfile:
        dir_name = zfile.namelist()[0].split('/')[0]
        print(dir_name)


    old_input_dir_file = os.path.join(app.config['INPUT_FOLDER'], dir_name)

    if os.path.exists(old_input_dir_file):
        shutil.rmtree(old_input_dir_file)

    zipping_success = unzip_file(zip_path, input_dir)

    if not zipping_success:
        return "error"

    if filename!= dir_name:
#        old_input_dir_file = os.path.join(app.config['INPUT_FOLDER'], dir_name)
        os.rename(old_input_dir_file, input_dir_file)

    with open("./docker-compose.yml","r") as f:
        template = f.read()
        template = template.format(filename,filename,filename)
    yml_name = "{}.yml".format(filename)
    yml_path = os.path.join(app.config['YML_FOLDER'], yml_name)
    with open( yml_path ,"w") as f:
        f.write(template)
    docker = DockerClient(compose_files=[yml_path])
    docker.compose.build()
    docker.compose.up()
    docker.compose.down()

    return "finished"


@app.route('/list_input_dir')
def list_input_dir():
    filenames = []
    for file in os.listdir(INPUT_PATH):
        filenames.append(file)
    return filenames

@app.route('/list_output_dir')
def list_output_dir():
    filenames = []
    for file in os.listdir(OUTPUT_PATH):
        filenames.append(file)
    return filenames


@app.route('/list_upload_dir')
def list_upload_dir():
    filenames = []
    for file in os.listdir(UPLOAD_PATH):
        filenames.append(file)
    return filenames


# @app.route('/search/<filename>')
# def download(filename):
#     filenames = []
#     for file in os.listdir(OUTPUT_PATH):
#         if file[:-3]=="mp4":
#             filenames.append({})
#     return filenames


@app.route('/download/<filename>')
def download(filename):
    return send_from_directory(OUTPUT_PATH, filename, as_attachment=True)

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8080, debug=True)
