#!/bin/bash

# start mqnamesrv service
nohup $ROCKETMQ_HOME/bin/mqnamesrv > /dev/null 2>&1 &
echo "启动：mqnamesrv"

# start mqbroker service
nohup $ROCKETMQ_HOME/bin/mqbroker -n localhost:9876 > /dev/null 2>&1 &
echo "启动：mqbroker"

# start console service
cd $CONSOLE_HOME
nohup  java -jar rocketmq-dashboard.jar > /dev/null 2>&1 &
echo "启动：console"
echo ""
echo "Console帐号以及密码"
echo "帐号：admin   密码：admin"
echo "帐号：normal  密码：normal"
echo ''
echo '      ___           ___           ___           ___           ___                       ___                   '
echo '     /  /\         /  /\         /  /\         /__/|         /  /\          ___        /__/\          ___     '
echo '    /  /::\       /  /::\       /  /:/        |  |:|        /  /:/_        /  /\      |  |::\        /  /\    '
echo '   /  /:/\:\     /  /:/\:\     /  /:/         |  |:|       /  /:/ /\      /  /:/      |  |:|:\      /  /::\   '
echo '  /  /:/~/:/    /  /:/  \:\   /  /:/  ___   __|  |:|      /  /:/ /:/_    /  /:/     __|__|:|\:\    /  /:/\:\  '
echo ' /__/:/ /:/___ /__/:/ \__\:\ /__/:/  /  /\ /__/\_|:|____ /__/:/ /:/ /\  /  /::\    /__/::::| \:\  /  /:/~/::\ '
echo ' \  \:\/:::::/ \  \:\ /  /:/ \  \:\ /  /:/ \  \:\/:::::/ \  \:\/:/ /:/ /__/:/\:\   \  \:\~~\__\/ /__/:/ /:/\:\'
echo '  \  \::/~~~~   \  \:\  /:/   \  \:\  /:/   \  \::/~~~~   \  \::/ /:/  \__\/  \:\   \  \:\       \  \:\/:/__\/'
echo '   \  \:\        \  \:\/:/     \  \:\/:/     \  \:\        \  \:\/:/        \  \:\   \  \:\       \  \::/     '
echo '    \  \:\        \  \::/       \  \::/       \  \:\        \  \::/          \__\/    \  \:\       \__\/      '
echo '     \__\/         \__\/         \__\/         \__\/         \__\/                     \__\/                  '
echo ''
echo "🚀版本：$ROCKETMQ_VERSION"
echo ""

# foreground process
tail -f /dev/null