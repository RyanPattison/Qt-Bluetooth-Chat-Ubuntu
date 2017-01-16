UBUNTU_MANIFEST_FILE=manifest.json.in

UBUNTU_TRANSLATION_DOMAIN="chat.rpattison"

UBUNTU_TRANSLATION_SOURCES+= \
    $$files(*.qml,true) \
    $$files(*.js,true)  \
    $$files(*.cpp,true) \
    $$files(*.h,true) \
    $$files(*.desktop,true)


UBUNTU_PO_FILES+=$$files(po/*.po)

TEMPLATE = app
TARGET = chat

load(ubuntu-click)

QML_FILES += $$files(*.qml,true) \
             $$files(*.js,true)

CONF_FILES +=  chat.apparmor \
               chat.png 

OTHER_FILES += $${CONF_FILES} \
               $${QML_FILES} \
               chat.rpattison.desktop 


#specify where the qml/js files are installed to
qml_files.path = /
qml_files.files += $${QML_FILES}

#specify where the config files are installed to
config_files.path = /
config_files.files += $${CONF_FILES}

desktop_file.path = /
desktop_file.files = $$OUT_PWD/chat.rpattison.desktop 
desktop_file.CONFIG += no_check_exist 

QT = core bluetooth quick
RESOURCES += chat.qrc

SOURCES += qmlchat.cpp

target.path = $${UBUNTU_CLICK_BINARY_PATH}
INSTALLS += target config_files qml_files desktop_file 
