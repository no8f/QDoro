#include "trayicon.h"

#include <QSystemTrayIcon>

TrayIcon* instPointer = nullptr;

using WinToastLib::WinToast, WinToastLib::WinToastTemplate;

class TrayIconPriv {
    friend class TrayIcon;

    QSystemTrayIcon* _tIcon = nullptr;
};

TrayIcon::TrayIcon(QObject *parent)
    : QObject{parent}
{
    if ( !instPointer )
        instPointer = this;

    _p = new TrayIconPriv();

    _p->_tIcon = new QSystemTrayIcon(this);
    _p->_tIcon->setIcon(QIcon(":/ressources/icons/ic_fluent_arrow_reset_24_filled.svg"));
    _p->_tIcon->show();

    WinToast::instance()->setAppName(L"QDoro");
    const auto aumi = WinToast::configureAUMI(L"no8f", L"QDoro", L"dashboard", L"0001");
    WinToast::instance()->setAppUserModelId(aumi);

    if (!WinToast::instance()->initialize()) {
        std::wcout << L"Error, could not initialize the lib!" << std::endl;
    }
}

TrayIcon::~TrayIcon()
{
    if ( instPointer == this )
        instPointer = nullptr;

    delete _p;
}

void TrayIcon::showNotification(const QString &title, const QString &message)
{
    WinToastTemplate templ = WinToastTemplate();

    templ.setFirstLine(L"Timer is up!");
    templ.setSecondLine(L"Starting next session");
    templ.setScenario(WinToastTemplate::Scenario::Reminder);

    templ.addAction(L"OK");
    templ.addAction(L"5 more minutes!");

    WinToast::WinToastError error;
    const auto toast_id = WinToast::instance()->showToast(templ, new QDoroWinToastHandler(), &error);
    if (toast_id < 0) {
        std::wcout << L"Error: Could not launch your toast notification!" << error << std::endl;
    }
}

TrayIcon *TrayIcon::inst()
{
    return instPointer == nullptr ? new TrayIcon() : instPointer;

}

QDoroWinToastHandler::QDoroWinToastHandler()
{

}

void QDoroWinToastHandler::toastActivated() const
{
    qDebug()<< "activated";
}

void QDoroWinToastHandler::toastActivated(int actionIndex) const
{
    qDebug()<< "activated" << actionIndex;
}

void QDoroWinToastHandler::toastActivated(const char *response) const
{
    qDebug()<< "activated" << response;
}

void QDoroWinToastHandler::toastDismissed(WinToastDismissalReason state) const
{
    qDebug() << "dismissed" << state;
}

void QDoroWinToastHandler::toastFailed() const
{
    qDebug() << "failed";
}
