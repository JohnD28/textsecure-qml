import QtQuick 2.2
import Ubuntu.Components 1.1
import Ubuntu.Components.Popups 1.0
import Ubuntu.PushNotifications 0.1

import 'components'
import 'ui'

MainView {
	applicationName: "textsecure.jani"

	automaticOrientation: false

	useDeprecatedToolbar: false

	anchorToKeyboard: true

	id: root

	property var messagesModel

	visible: true
	width: units.gu(45)
	height: units.gu(80)

	PageStack {
		id: pageStack

		Component {
			id: dialogPage
			DialogPage {}
		}

		Component {
			id: dialogsPage
			DialogsPage {}
		}

		Component {
			id: contactsPage
			ContactsPage {}
		}

		Component {
			id: settingsPage
			SettingsPage {}
		}

		Component {
			id: verifyCodePage
			VerificationCodePage {}
		}

		Component {
			id: passwordPage
			PasswordPage {}
		}

		Component {
			id: signInPage
			SignInPage {}
		}

		Component {
			id: picker
			PickerPage {}
		}

		Component {
			id: previewPage
			PreviewPage {}
		}

		Component {
			id: introPage
			IntroPage {}
		}

		Component.onCompleted: initialize()
	}

	PushClient {
		id: pushClient
		appId: "textsecure.jani_textsecure"
		onTokenChanged: {
			//console.log("Push client token is", token)
		}
	}

	function initialize() {
		pageStack.push(dialogsPage)
	}

	function getPhoneNumber() {
		pageStack.push(signInPage)
	}

	function getVerificationCode() {
		pageStack.push(verifyCodePage)
	}

	function registered() {
		pageStack.push(dialogsPage)
	}

	function error(errorMsg) {
		var properties = {'text':errorMsg}
		PopupUtils.open(Qt.resolvedUrl("ui/dialogs/ErrorMessageDialog.qml"), root, properties)
	}

	function openSettings() {
		pageStack.push(settingsPage);
	}

	function openHelp() {
                Qt.openUrlExternally("https://github.com/janimo/textsecure-qml/issues")
	}

	function newChat() {
		openContacts(false);
	}

	function newGroupChat() {
		openContacts(true);
	}

	function markAllRead() {
		textsecure.markSessionsRead("")
	}

	function getStoragePassword() {
		pageStack.push(passwordPage)
	}

	function openContacts(groupChatMode) {
		var properties = { groupChatMode: groupChatMode };
		pageStack.push(contactsPage, properties);
	}

	function backToDialogsPage() {
		while (pageStack.depth > 0 &&
		pageStack.currentPage.objectName !== "dialogsPage") {
			pageStack.pop();
		}
		if (pageStack.depth === 0) {
			pageStack.push(dialogsPage);
		}
	}

	function openChatById(chatId, tel, properties) {
		if (pageStack.depth > 0 && pageStack.currentPage.objectName === "chatPage") {
			if (pageStack.currentPage.chatId === chatId) return;
		}
		if (typeof properties === "undefined") properties = { };
		backToDialogsPage();
		textsecure.activeSessionID = tel
		textsecure.markSessionsRead(tel)
		messagesModel = sessionsModel.get(tel);
		properties['chatId'] = uid(tel);
		pageStack.push(dialogPage, properties);
	}

	function forwardMessages(messages) {
		var properties = { messagesToForward: messages };
		console.log(messages)
		pageStack.push(dialogsPage, properties);
	}

	function uid(tel) {
		return parseInt(tel.substring(3, 10), 16)
	}

	function avatarImage(id) {
		return textsecure.avatarImage(id)
	}
}
