# WebAPI-B4J
Version: 1.15

A boilerplate for creating REST API Server with CRUD functionalities.

**Check the Wiki!** https://github.com/pyhoon/webapi-b4j/wiki

**B4X Client app:** https://github.com/pyhoon/webapi-client-b4x


## Depends on following libraries:
- ByteConverter
- JavaObject
- jServer (note that version 1.12+ is based on jServer 4.0)
- Json
- jSQL

# Features
- CRUD based - **REST**ful-API style (GET, POST, PUT, DELETE)
- Front-end (HTML, CSS, JS, **Bootstrap**)
- Support **MySQL** and **SQLite** database (can be modified for MS SQL or SQL Express)
- Separate SQL queries file (queries-mysql.ini and queries-sqlite.ini)
- Sample database auto-generated for first run (Category and Product tables with dummy data)
- Versioning (using ROOT_PATH in config.ini, set as "/" if you don't want versioning)
- Auto generated documentation with API test.

# Create B4X template from source
1. Archive the files inside "Web API" directory as "Web API Server (1.15).zip" using WinRAR or 7-Zip
2. Rename the extension from .zip to .b4xtemplate

# How to use
1. Download "Web.API.Server.1.15.b4xtemplate" from Release (https://github.com/pyhoon/webapi-b4j/releases). Rename it to "Web API Server (1.15).b4xtemplate".
2. Copy the "Web API Server (1.15).b4xtemplate" file into B4J Additional Libraries folder.
3. Open B4J and create a new project with "Web API" template. Give the project a name, for e.g. WebAPI
4. Run the project in Debug or Release mode. You will see something like this in the Logs:
```
Web API Server (version = 1.15) is running on port 19800
Open the following URL from your web browser
http://127.0.0.1:19800/v1/
```
5. Copy the URL showed in Logs and open it using your web browser.
6. To connect to MySQL server, go to Objects folder and open "config.ini".
7. Edit the root password at line #42 (second last line). Save the file.
8. In B4J project, comment the line '#AdditionalJar: sqlite-jdbc-3.39.3.0 and uncomment the line #AdditionalJar: mysql-connector-java-5.1.49-bin. (Make sure you are using the correct version of connector)
9. Follow step #4 to #5 above.

**Preview**
<img src="https://github.com/pyhoon/webapi-b4j/raw/main/Preview/web-api-01.png" title="Homepage" />
<img src="https://github.com/pyhoon/webapi-b4j/raw/main/Preview/web-api-02.png" title="Category" />
<img src="https://github.com/pyhoon/webapi-b4j/raw/main/Preview/web-api-03.png" title="Documentation" />

**YouTube**

[![Alt text](https://img.youtube.com/vi/umSSfja5Dzg/0.jpg)](https://youtu.be/umSSfja5Dzg)

Made with ❤ in B4X

Download and Develop with B4J for FREE: https://www.b4x.com/b4j.html
