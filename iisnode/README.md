# iisnode

It is possible the run the application in iisnode. (MS Internet Information Server).

- First install nodejs/R  (see installation)
- 
- install iisnode
- install urlrewrite
- Copy `web.config` into `..`
- add the CSPA_REST directory as a virtual path to the webserver. e.g. "CSPA" so its address will be e.g. "http://my_server/CPSA"
- Adjust the key: "VPATH" so that is matches the virtual path of the CSPA: e.g. "CSPA/"  **Note the terminating "/"**

