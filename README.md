# webapi-b4j
Version: 1.12

A boilerplate for creating CRUD based Web API.

**Depends on following libraries:** ByteConverter, JavaObject, jServer (note that version 1.12 is based on jServer 4.0), Json, jSQL

**B4X Client app:** https://github.com/pyhoon/webapi-client-b4x

# Features
- CRUD based - REST-API style (GET, POST, PUT, DELETE)
- Front-end (HTML, CSS, JS, Bootstrap)
- Support **MySQL** and **SQLite** database (can be modified for MS SQL or SQL Express)
- Separate SQL queries file (queries-mysql.ini and queries-sqlite.ini)
- Sample database auto-generated for first run (Category and Product tables with dummy data)
- Versioning (using ROOT_PATH in config.ini, set as "/" if you don't want versioning)
- Auto generated documentation with API test.

# Create B4X template from source
1. Archive the files inside "Web API" directory as "Web API.zip" using WinRAR or 7-Zip
2. Rename the extension from .zip to .b4xtemplate

# How to use
1. Download "Web.API.b4xtemplate" from Release (https://github.com/pyhoon/webapi-b4j/releases). Rename it to "Web API.b4xtemplate".
2. Copy the "Web API.b4xtemplate" file into B4J Additional Libraries folder.
3. Open B4J and create a new project with "Web API" template. Give the project a name, for e.g. WebAPI
4. Run the project in Debug or Release mode. You will see something like this in the Logs:
```
Web API server (version = 1.12) is running on port 19800
Open the following URL from your web browser
http://127.0.0.1:19800/v1/
```
4. Copy the URL showed in Logs and open it using your web browser.
5. To connect to MySQL server, go to Objects folder and open "config.ini".
6. Edit the root password at line #42 (second last line). Save the file.
7. In B4J project, comment the line '#AdditionalJar: sqlite-jdbc-3.36.0.2 and uncomment the line #AdditionalJar: mysql-connector-java-5.1.49-bin. (Make sure you are using the correct version of connector)
8. Follow step #3 above.

**Preview**
<img src="https://github.com/pyhoon/webapi-b4j/raw/main/Preview/web-api.png" title="Web API" />

**YouTube**

[![Alt text](https://img.youtube.com/vi/siTGmm726zI/0.jpg)](https://youtu.be/siTGmm726zI)

Made with ??? in B4X

Download and Develop with B4J for FREE: https://www.b4x.com/b4j.html
