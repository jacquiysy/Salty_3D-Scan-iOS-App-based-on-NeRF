import os
from flask import Flask
from flask import render_template, flash, request, redirect, url_for, send_from_directory
from werkzeug.utils import secure_filename
from python_on_whales import DockerClient
import shutil
import zipfile
from flask_sqlalchemy import SQLAlchemy
from  flask_login import LoginManager, login_required, login_user,logout_user
import moviepy.editor as mp
import json
app = Flask(__name__)

UPLOAD_FOLDER = 'upload'
INPUT_FOLDER = 'input'
OUTPUT_FOLDER = 'output'
YML_FOLDER = 'ymls'

UPLOAD_PATH = os.path.join(app.root_path,UPLOAD_FOLDER)
INPUT_PATH = os.path.join(app.root_path,INPUT_FOLDER)
OUTPUT_PATH = os.path.join(app.root_path,OUTPUT_FOLDER)
YML_PATH = os.path.join(app.root_path,YML_FOLDER)
SECRET_KEY = os.urandom(32)
# ALLOWED_EXTENSIONS = {'zip'}

app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
app.config['INPUT_FOLDER'] = INPUT_FOLDER
app.config['OUTPUT_FOLDER'] = OUTPUT_FOLDER
app.config['YML_FOLDER'] = YML_FOLDER
app.config['SESSION_TYPE'] = 'filesystem'
app.config['SECRET_KEY'] = SECRET_KEY
app.config['SQLALCHEMY_DATABASE_URI'] = 'sqlite:///mydb.db'
app.config['SQLALCHEMY_TRACK_MODIFICATIONS'] = False
db = SQLAlchemy(app)
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
                os.remove(file_path)
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
    
#    print(zip_path)
    zipping_success = unzip_file(zip_path, input_dir)
    
#    print(input_dir, input_dir_file)
#    frame_num = os.listdir(os.path.join(input_dir,filename,"images"))
#    print(frame_num)
    
#    frame_num = len(frame_num)

    if not zipping_success:
        return "error"

    if filename!= dir_name:
#        old_input_dir_file = os.path.join(app.config['INPUT_FOLDER'], dir_name)
        os.rename(old_input_dir_file, input_dir_file)
    
    frame_num = os.listdir(os.path.join(input_dir,filename,"images"))
    print(frame_num)
    frame_num = len(frame_num)

    #Make dir and copy cover image
    output_dir_name = os.path.join(app.config['OUTPUT_FOLDER'], filename)
    if os.path.exists(output_dir_name):
        shutil.rmtree(output_dir_name)
    os.mkdir(output_dir_name)

    source_image = os.path.join(input_dir_file,"images/0.png")
    target_image = os.path.join(output_dir_name,filename +".png")
    shutil.copy(source_image, target_image)
    
    with open(os.path.join(input_dir_file,'transforms.json'), 'r') as f:
        load_dict = json.load(f)
        load_dict["scale"]=1
        load_dict["aabb_scale"]=1
        
    with open(os.path.join(input_dir_file,'transforms.json'), 'w', encoding='utf-8') as f2:
        json.dump(load_dict, f2, ensure_ascii=False)

    with open("./docker-compose.yml","r") as f:
        template = f.read()
        template = template.format(filename, filename,filename)
    
    yml_name = "{}.yml".format(filename)
    yml_path = os.path.join(app.config['YML_FOLDER'], yml_name)
    with open( yml_path ,"w") as f:
        f.write(template)
    docker = DockerClient(compose_files=[yml_path])
    
    docker.compose.build()
    docker.compose.up()
    docker.compose.down()
    
    shutil.move(os.path.join(app.config["OUTPUT_FOLDER"],filename + ".obj"),os.path.join(output_dir_name, filename + ".obj"))
    shutil.move(os.path.join(app.config["OUTPUT_FOLDER"],filename + ".mp4"),os.path.join(output_dir_name, filename + ".mp4"))
    
    zipping_path = os.path.join(output_dir_name, filename + ".zip")
    z = zipfile.ZipFile(zipping_path,'w')
    z.write(os.path.join(output_dir_name, filename + ".obj"))
    z.close()
    
    clips = mp.VideoFileClip(os.path.join(output_dir_name,filename + ".mp4"))
    clips.write_gif(os.path.join(output_dir_name,filename + ".gif"))
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
    file_return = {"filenames":filenames}
    return file_return


@app.route('/list_upload_dir')
def list_upload_dir():
    filenames = []
    for file in os.listdir(UPLOAD_PATH):
        filenames.append(file)
    return filenames


@app.route('/search/<filename>')
def search(filename):
    filenames = []
    #keyword = filename
   
    for files in os.listdir(app.config["OUTPUT_FOLDER"]):
        if filename.lower() in files.lower():
            filenames.append(files)
    return filenames


@app.route('/download/<filename>')
def download(filename):
    filename_head = filename.split(".")[0]
    OUTPUT_TMP = os.path.join(OUTPUT_PATH,filename_head)
    print(os.path.join(OUTPUT_TMP,filename))
    if not os.path.exists(os.path.join(OUTPUT_TMP,filename)):
        return ("Not exist")
    return send_from_directory(OUTPUT_TMP, filename, as_attachment=True)




from flask_login import LoginManager
login_manager = LoginManager()
login_manager.init_app(app)

from flask_login import UserMixin
from datetime import datetime

from werkzeug.security import generate_password_hash, check_password_hash


class User(UserMixin, db.Model):
  id = db.Column(db.Integer, primary_key=True)
  username = db.Column(db.String(50), index=True, unique=True)
  email = db.Column(db.String(150), unique = True, index = True)
  password_hash = db.Column(db.String(150))
  joined_at = db.Column(db.DateTime(), default = datetime.utcnow, index = True)

  def set_password(self, password):
        self.password_hash = generate_password_hash(password)

  def check_password(self,password):
      return check_password_hash(self.password_hash,password)
  
#user loader to fetch current user id
@login_manager.user_loader
def load_user(user_id):
    return User.get(user_id)

# Route for logging in

# Create a new user object with the username 'admin'
#admin = User(username='admin', email='admin@example.com')
#admin.set_password('admin')

# Add the new user to the database
#db.session.add(admin)
#db.session.commit()
# Create a Flask application context
with app.app_context():
    # Create the users table
    db.create_all()

@app.route('/login', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        # Get the username and password from the form
        username = request.form['username']
        password = request.form['password']
        user = User.query.filter_by(username=username).first()

        # Check if the user exists and if the entered password is correct
        if user is not None and user.check_password(password):
            # Log the user in
            login_user(user)
            return"login success"
            # return redirect(url_for('index'))
        else:
            return 'login failed'

@app.route('/register', methods=['GET', 'POST'])
def register():
    if request.method == 'POST':
        # Get the username, email, and password from the form
        username = request.form['username']
        email = request.form['email']
        password = request.form['password']


        user = User(username=username, email=email)
        user.set_password(password)

        # Add the new user to the database
        db.session.add(user)
        db.session.commit()

        # Redirect to the login page
        return 'register success'
        # return redirect(url_for('login'))
    else:
        return 'register failed'


@app.route("/logout")
# @login_required
def logout():
    logout_user()
    return redirect(url_for('home'))

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8080, debug=True)
