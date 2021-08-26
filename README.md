# webapi-b4j
A boilerplate for creating CRUD based Web API.

# Features:
- CRUD based - REST-API style (GET, POST, PUT, DELETE)
- Front-end (HTML, CSS, JS, Bootstrap)
- Support MySQL database (Can be modified for MS SQL or SQL Express)
- Separate SQL queries file (query.ini)
- Sample database auto-generated for first run (Category and Product tables with dummy data)
- Versioning (using ROOT_PATH in config.ini, set as "/" if you don't want versioning)

# How to use:
1. Copy the "Web API.b4xtemplate" file into B4J platform Additional folder.
2. Open B4J and create new project with template "Web API". Give your project any name you like.
3. Go to Objects folder and edit "config.ini" at line #32 (second last line) to set the MySQL root password to your password. Save the file.
4. Run the project in Debug or Release mode.
5. Copy the URL showed in logs and open it using your web browser. You will see something like this:
`http://127.0.0.1:19800/v1/`

![alt text](image.jpg)
