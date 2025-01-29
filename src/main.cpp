#include <QApplication>
#include <QPalette>
#include <QQmlApplicationEngine>
#include <QQuickWindow>
#include <QQuickStyle>
#include <QStyleHints>
#include <QTimer>

#ifdef Q_OS_WIN
#include <dwmapi.h>
#endif

#include <trayicon.h>

int main(int argc, char *argv[])
{
    QApplication app(argc, argv);

#ifdef Q_OS_WIN
    QQuickStyle::setStyle("FluentWinUI3");
#endif

    QPixmap transparentPixmap(1, 1);
    transparentPixmap.fill(Qt::transparent);
    QIcon transparentIcon(transparentPixmap);

    app.setWindowIcon(transparentIcon);

    QQuickWindow::setGraphicsApi(QSGRendererInterface::Vulkan);

    qmlRegisterSingletonType<TrayIcon>("QDoro", 1, 0, "QDoroTrayIcon", [](QQmlEngine*, QJSEngine*){ return TrayIcon::inst(); });

    QQmlApplicationEngine engine;
    QObject::connect(
        &engine,
        &QQmlApplicationEngine::objectCreationFailed,
        &app,
        []() { QCoreApplication::exit(-1); },
        Qt::QueuedConnection);
    engine.loadFromModule("QDoro", "Main");

    auto *window = qobject_cast<QQuickWindow *>(engine.rootObjects().constFirst());

#ifdef Q_OS_WIN
    HWND hwnd = reinterpret_cast<HWND>(window->winId());

    auto setTitleColor = [](const QQuickWindow *window, HWND hwnd) {
        // QColor bc = window->property("color").value<QColor>();
        // COLORREF color = RGB(bc.red(), bc.green(), bc.blue());
        // DwmSetWindowAttribute(hwnd, DWMWINDOWATTRIBUTE::DWMWA_CAPTION_COLOR, &color, sizeof(color));
    };

    QObject::connect(app.styleHints(), &QStyleHints::colorSchemeChanged, &app, [window, hwnd, setTitleColor]() {
        QTimer::singleShot(10, [hwnd, setTitleColor, window]() {setTitleColor(window, hwnd);});
    });

    setTitleColor(window, hwnd);
#endif

    return app.exec();
}
