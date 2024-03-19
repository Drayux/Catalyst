import QtQuick 2.5
import QtQuick.Window 2.2

Rectangle {
    id: root
    color: "#be5745"
    property int stage

    onStageChanged: {
        if (stage == 1) {
            introAnimation.running = true;
        } else if (stage == 5) {
            introAnimation.target = busyIndicator;
            introAnimation.from = 1;
            introAnimation.to = 0;
            introAnimation.running = true;
        }
    }

    /* Positioning container for the images */
    Rectangle {
        id: content
        height: 1280
        color: "transparent"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.verticalCenter: parent.verticalCenter

        property int pos_y : 800

        /* TODO: change me to the hearts animation */
        AnimatedImage {
            id: hearts
            source: "images/loading.gif"
            height: parent.height
            width: parent.height * (16 / 9)
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }

        /*Image {
            id: cerebus
            source: "images/cerebus.png"
            sourceSize.height: parent.height
            sourceSize.width: parent.width
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.verticalCenter: parent.verticalCenter
        }*/
    }

    OpacityAnimator {
        id: introAnimation
        running: false
        target: content
        from: 0
        to: 1
        duration: 500
        easing.type: Easing.InOutQuad
    }
}

/*Image {
    id: root
    property int stage

    onStageChanged: {
        if (stage == 1) {
            introAnimation.running = true
        }
    }
    Image {
        id: topRect
        anchors.horizontalCenter: parent.horizontalCenter
        y: root.height /3
        source: "images/rectangle.svg"
        Image {
            source: "images/kde.svg"
            anchors.centerIn: parent
        }
        Rectangle {
            radius: 3
            color: "#55555574"
            anchors {
                bottom: parent.bottom
                bottomMargin: 50
                horizontalCenter: parent.horizontalCenter
            }
            height: 6
            width: height*36
            Rectangle {
                radius: 3
                anchors {
                    left: parent.left
                    top: parent.top
                    bottom: parent.bottom
                }
                width: (parent.width / 6) * (stage - 1)
                color: "#d33346"
                Behavior on width { 
                    PropertyAnimation {
                        duration: 250
                        easing.type: Easing.InOutQuad
                    }
                }
            }
        }
    }

    SequentialAnimation {
        id: introAnimation
        running: false
        ParallelAnimation {
            PropertyAnimation {
                property: "opacity"
                target: topRect
                from: 0
                to: 1
                duration: 1000
                easing.type: Easing.InOutBack
                easing.overshoot: 1.0
            }

            PropertyAnimation {
                property: "opacity"
                target: bottomRect
                from: 0
                to: 1
                duration: 1000
                easing.type: Easing.InOutBack
                easing.overshoot: 1.0
            }
        }
    }
}
*/
