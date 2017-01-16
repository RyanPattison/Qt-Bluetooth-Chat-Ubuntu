/****************************************************************************
**
** Copyright (C) 2015 The Qt Company Ltd.
** Contact: http://www.qt.io/licensing/
**
** This file is part of the examples of the QtBluetooth module.
**
** $QT_BEGIN_LICENSE:BSD$
** You may use this file under the terms of the BSD license as follows:
**
** "Redistribution and use in source and binary forms, with or without
** modification, are permitted provided that the following conditions are
** met:
**   * Redistributions of source code must retain the above copyright
**	 notice, this list of conditions and the following disclaimer.
**   * Redistributions in binary form must reproduce the above copyright
**	 notice, this list of conditions and the following disclaimer in
**	 the documentation and/or other materials provided with the
**	 distribution.
**   * Neither the name of The Qt Company Ltd nor the names of its
**	 contributors may be used to endorse or promote products derived
**	 from this software without specific prior written permission.
**
**
** THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
** "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
** LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR
** A PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT
** OWNER OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL,
** SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT
** LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
** DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
** THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
** (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
** OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE."
**
** $QT_END_LICENSE$
**
****************************************************************************/

import QtQuick 2.2
import QtBluetooth 5.3
import Ubuntu.Components 1.3

MainView {
	id: top
	width: units.gu(40)
	height: units.gu(80)

	Component.onCompleted: state = "begin"

	property string remoteDeviceName: ""
	property bool serviceFound: false
	property bool animationRunning: true

	BluetoothDiscoveryModel {
		id: btModel
		running: true
		discoveryMode: BluetoothDiscoveryModel.MinimalServiceDiscovery
		onRunningChanged : {
			if (!btModel.running && top.state == "begin" && !serviceFound) {
				animationRunning = false;
				searchBox.appendText("\nNo service found. \n\nPlease start server\nand restart app.")
			}
		}

		onErrorChanged: {
			if (error != BluetoothDiscoveryModel.NoError && !btModel.running) {
				animationRunning = false
				searchBox.appendText("\n\nDiscovery failed.\nPlease ensure Bluetooth is available.")
			}
		}

		onServiceDiscovered: {
			if (serviceFound)
				return
			serviceFound = true
			console.log("Found new service " + service.deviceAddress + " " + service.deviceName + " " + service.serviceName);
			searchBox.appendText("\nConnecting to server...")
			remoteDeviceName = service.deviceName
			socket.setService(service)
		}
		uuidFilter: "e8e10f95-1a70-4b27-9ccf-02010264e9c8"
	}

	BluetoothSocket {
		id: socket
		connected: true

		onSocketStateChanged: {
			console.log("Connected to server")
			top.state = "chatActive"
		}

		onStringDataChanged: {
			console.log("Received data: " )
			var data = remoteDeviceName + ": " + socket.stringData;
			data = data.substring(0, data.indexOf('\n'))
			chatContent.append({content: data})
			console.log(data);
		}
	}

	ListModel {
		id: chatContent
		ListElement {
			content: "Connected to chat server"
		}
	}


	Page {
		id: searchBox

		header: PageHeader {
			id: searchHeader
			title: "Searching"
		}

		function appendText(newText) {
			searchText.text += newText
		}

		Behavior on height {
			UbuntuNumberAnimation { }
		}

		Icon {
			anchors.top: searchHeader.bottom
			anchors.topMargin: units.gu(8)
			anchors.horizontalCenter: parent.horizontalCenter
			width: units.gu(18)
			height: units.gu(18)

			id: bluetoothImage
			name: "bluetooth-active"	
			color: UbuntuColors.blue
			
			UbuntuNumberAnimation on opacity {
				id: ranimation
				target: bluetoothImage
				property: "opacity"
				from: 0
				to: 1
				duration: UbuntuAnimation.SleepyDuration
				loops: Animation.Infinite
				    
				alwaysRunToEnd: true
				running: animationRunning
			}
		}
	
		Label {
			id: searchText
			anchors.top: bluetoothImage.bottom
			anchors.topMargin: units.gu(3)
			anchors.horizontalCenter: parent.horizontalCenter
			text: qsTr("Searching for chat service...");
			fontSize: "large" //Label.XLarge
		}
	}

	Page {
		id: chatBox
		header: PageHeader {
			id: chatHeader
			title: "Chat Room"
		}
		opacity: 0

		function sendMessage()
		{
			// toggle focus to force end of input method composer
			var hasFocus = input.focus;
			input.focus = false;

			var data = input.text
			input.text = "";
			chatContent.append({content: "Me: " + data})
			socket.stringData = data
			chatView.positionViewAtEnd()

			input.focus = hasFocus;
		}

		TextField {
			id: input
			Keys.onReturnPressed: chatBox.sendMessage()
			height: sendButton.height
			anchors.top: chatHeader.bottom
			anchors.topMargin: units.gu(1)
			anchors.left: parent.left
			anchors.leftMargin: units.gu(1)
			anchors.right: sendButton.left
			anchors.rightMargin: units.gu(1)
			hasClearButton: true
		}

		Button {
			id: sendButton
			anchors.right: parent.right
			anchors.rightMargin: units.gu(1)
			anchors.top: chatHeader.bottom
			anchors.topMargin: units.gu(1)
		
			text: "Send"
			onClicked: chatBox.sendMessage()
			color: UbuntuColors.green
		}

		ListView {
			id: chatView
			anchors.top: sendButton.bottom
			anchors.topMargin: units.gu(2)
			anchors.bottom: parent.bottom
			width: parent.width

			model: chatContent
			clip: true
			delegate: Component {
				ListItem {
					height: layout.height + (divider.visible ? divider.height : 0)
					ListItemLayout {
						id: layout
						title.text: modelData
					}
				}
			}
		}
	}

	states: [
		State {
			name: "begin"
			PropertyChanges { target: searchBox; opacity: 1 }
			PropertyChanges { target: chatBox; opacity: 0 }
		},
		State {
			name: "chatActive"
			PropertyChanges { target: searchBox; opacity: 0 }
			PropertyChanges { target: chatBox; opacity: 1 }
		}
	]
}
