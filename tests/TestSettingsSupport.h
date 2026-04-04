#ifndef TESTSETTINGSSUPPORT_H
#define TESTSETTINGSSUPPORT_H

#include "../src/Core/AppConstants.h"

#include <QCoreApplication>
#include <QSettings>
#include <QTemporaryDir>

class ScopedSettingsStore
{
public:
    ScopedSettingsStore()
    {
        Q_ASSERT(m_tempDir.isValid());
        QSettings::setDefaultFormat(QSettings::IniFormat);
        QSettings::setPath(QSettings::IniFormat, QSettings::UserScope, m_tempDir.path());
        QSettings::setPath(QSettings::IniFormat, QSettings::SystemScope, m_tempDir.path());
        QCoreApplication::setOrganizationName(AppConstants::ORG_NAME);
        QCoreApplication::setApplicationName(AppConstants::APP_NAME);

        QSettings settings(AppConstants::ORG_NAME, AppConstants::APP_NAME);
        settings.clear();
        settings.sync();
    }

    QSettings settings() const
    {
        return QSettings(AppConstants::ORG_NAME, AppConstants::APP_NAME);
    }

private:
    QTemporaryDir m_tempDir;
};

#endif  // TESTSETTINGSSUPPORT_H
