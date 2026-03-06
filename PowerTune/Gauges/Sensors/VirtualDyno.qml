import QtQuick 2.15

import QtCharts 2.1

import QtQuick.Controls 2.15



Item {

    anchors.fill: parent

    property double finalkw

    property double finalnm

    property double kw

    property double nm

    property double previousrpm







    ChartView {

        title: "Virtual Dyno"

        id: chartView

        theme: ChartView.ChartThemeDark

        anchors.fill: parent

        legend.visible: true

        antialiasing: false



        Row {

            x: 5

            y: 5

            spacing: 5

            Button {

                id: startButton

                text: "Start"

                onClicked: {

                    if (refreshTimer.running == false) refreshTimer.running = true, previousrpm = Engine.rpm, finalkw =0, finalnm =0;





                }

            }

            Button {

                id: stopButton

                text: "clear"

                onClicked: {

                    series2.clear(),series1.clear();



                }

            }

        }

        ValueAxis {

            id: axisX

            min: 0

            max: 9000

            tickCount: 10

        }



        ValueAxis {

            id: axisY1

            min: 0

            max: 700

        }





        SplineSeries {

            id: series1

            name: "KW"

            axisX: axisX

            axisY: axisY1

        }



        SplineSeries {

            id: series2

            name: "NM"

            axisX: axisX

            axisY: axisY1

        }

    }



    //





    // Add data dynamically to the series

    Timer {



        id: refreshTimer

        interval: 50

        running: false

        repeat: true

        onTriggered: {



            if (previousrpm <= Engine.rpm)

            {

            speed ++

            previousrpm = Engine.rpm



            kw = ((((1300)*(Vehicle.speed / 3.6) * ((Vehicle.speed / 3.6)))) /1000)

            nm = ((9.5488 * kw *1000) / Engine.rpm)



            if (finalkw < kw)

            {finalkw = kw}

            if (finalnm < nm)

            {finalnm = nm}



            finalnm

            series1.append(Engine.rpm, kw);

            series2.append(Engine.rpm, nm);

            }

            if (previousrpm > Engine.rpm) {refreshTimer.running = false}



        }

    }

}
