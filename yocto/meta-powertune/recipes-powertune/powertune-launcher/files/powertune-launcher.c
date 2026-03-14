/*
 * powertune-launcher.c
 *
 * Native process launcher for the PowerTune Digital Dashboard.
 * Replaces the legacy chain of shell scripts (startdaemon.sh, bootsplash,
 * bash init wrappers) with a single compiled binary that:
 *
 *   1. Sets required Qt/EGLFS environment variables
 *   2. Redirects stdout/stderr to the application log
 *   3. exec()'s PowerTuneQMLGui directly
 *
 * Designed to be invoked from inittab with the 'respawn' action so that
 * init(8) automatically restarts the dashboard if it exits or crashes.
 *
 * A maintenance-mode flag file (/tmp/powertune-maintenance) gates launch
 * to allow clean stops during deployment without fighting respawn.
 */

#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/stat.h>
#include <unistd.h>

#define APP_DIR   "/opt/PowerTune"
#define APP_BIN   APP_DIR "/PowerTuneQMLGui"
#define APP_LOG   "/var/log/powertune.log"
#define MAINT_FLAG "/tmp/powertune-maintenance"
#define MAINT_SLEEP 5

struct env_pair {
    const char *key;
    const char *value;
};

static const struct env_pair qt_env[] = {
    { "HOME",                         "/home/root"               },
    { "LC_ALL",                       "en_US.utf8"               },
    { "QT_QPA_PLATFORM",             "eglfs"                    },
    { "QT_QPA_EGLFS_HIDECURSOR",    "1"                        },
    { "QT_QPA_EGLFS_ALWAYS_SET_MODE","1"                        },
    { "QT_QPA_EGLFS_KMS_ATOMIC",    "1"                        },
    { "QT_QPA_EGLFS_KMS_CONFIG",    APP_DIR "/kms-config.json" },
    { "QML_DISK_CACHE",              "1"                        },
    { NULL, NULL }
};

int main(void)
{
    if (access(MAINT_FLAG, F_OK) == 0) {
        sleep(MAINT_SLEEP);
        return 0;
    }

    for (const struct env_pair *p = qt_env; p->key != NULL; p++)
        setenv(p->key, p->value, 1);

    if (chdir(APP_DIR) != 0) {
        perror("chdir " APP_DIR);
        return 1;
    }

    int logfd = open(APP_LOG, O_WRONLY | O_CREAT | O_TRUNC, 0644);
    if (logfd >= 0) {
        dup2(logfd, STDOUT_FILENO);
        dup2(logfd, STDERR_FILENO);
        close(logfd);
    }

    execl(APP_BIN, "PowerTuneQMLGui", "-platform", "eglfs", (char *)NULL);

    perror("exec " APP_BIN);
    return 1;
}
