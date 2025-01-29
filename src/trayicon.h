#ifndef TRAYICON_H
#define TRAYICON_H

#include <QObject>
#include <QQmlEngine>

#include <wintoastlib.h>

using WinToastLib::IWinToastHandler;
class QDoroWinToastHandler : public IWinToastHandler {
public:
    QDoroWinToastHandler();
    // Public interfaces
    void toastActivated() const override;
    void toastActivated(int actionIndex) const override;
    void toastActivated(const char* response) const override;
    void toastDismissed(WinToastDismissalReason state) const override;
    void toastFailed() const override;
};

class TrayIconPriv;
class TrayIcon : public QObject
{
    Q_OBJECT
    QML_ELEMENT
    QML_SINGLETON

public:
    ~TrayIcon();

    Q_INVOKABLE void showNotification(const QString &title, const QString &message);

    static TrayIcon *inst();

protected:
    explicit TrayIcon(QObject *parent = nullptr);

private:
    TrayIconPriv *_p = nullptr;

signals:
};

#endif // TRAYICON_H
