# webapi-b4j
A boilerplate for creating CRUD based Web API.

**Depends on following libraries:** ByteConverter, JavaObject, jServer, Json, jSQL

# Features:
- CRUD based - REST-API style (GET, POST, PUT, DELETE)
- Front-end (HTML, CSS, JS, Bootstrap)
- Support **MySQL** and **SQLite** database (Can be modified for MS SQL or SQL Express)
- Separate SQL queries file (queries-mysql.ini and queries-sqlite.ini)
- Sample database auto-generated for first run (Category and Product tables with dummy data)
- Versioning (using ROOT_PATH in config.ini, set as "/" if you don't want versioning)

# How to use:
1. Copy the "Web API.b4xtemplate" file into B4J platform Additional folder.
2. Open B4J and create a new project with "Web API" template. Give your project any name you like, for e.g. WebAPI
3. Run the project in Debug or Release mode. You will see something like this in the Logs:
```
Web API server (version = 1.06) is running on port 19800
Open the following URL from your web browser
http://127.0.0.1:19800/v1/
```
4. Copy the URL showed in Logs and open it using your web browser.
5. To connect to MySQL server, go to Objects folder and open "config.ini".
6. Edit the root password at line #42 (second last line). Save the file.
7. In B4J project, comment the line '#AdditionalJar: sqlite-jdbc-3.36.0.2 and uncomment the line #AdditionalJar: mysql-connector-java-5.1.49-bin.​
Make sure you are using the correct version of connector.
8. Follow step #3 above.

**Preview:**
<img src="https://github.com/pyhoon/webapi-b4j/raw/main/Preview/web-api.png" title="Web API" />

**Video**
https://youtu.be/Y-1HDR2k_fE
