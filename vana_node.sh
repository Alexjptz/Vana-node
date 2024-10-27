#!/bin/bash

tput reset
tput civis

# Put your logo here if nessesary

show_orange() {
    echo -e "\e[33m$1\e[0m"
}

show_blue() {
    echo -e "\e[34m$1\e[0m"
}

show_green() {
    echo -e "\e[32m$1\e[0m"
}

show_red() {
    echo -e "\e[31m$1\e[0m"
}

version_ge() {
    [ "$(printf '%s\n' "$1" "$2" | sort -V | head -n1)" = "$2" ]
}

show_orange " ____    ____      ___      .__   __.      ___ " && sleep 0.2
show_orange " \   \  /   /     /   \     |  \ |  |     /   \ " && sleep 0.2
show_orange "  \   \/   /     /  ^  \    |   \|  |    /  ^  \ " && sleep 0.2
show_orange "   \      /     /  /_\  \   |  .    |   /  /_\  \ " && sleep 0.2
show_orange "    \    /     /  _____  \  |  |\   |  /  _____  \ " && sleep 0.2
show_orange "     \__/     /__/     \__\ |__| \__| /__/     \__\ " && sleep 0.2
echo ""
sleep 1

while true; do
    echo "1. Подготовка к установке VANA (Preparation)"
    echo "2. Установить VANA (Installation)"
    echo "3. Создать/Восстановить кошельки (Create/Restore Wallets)"
    echo "4. Деплой контракта в MOKSHA (Deploy)"
    echo "5. Установка Валидатора (Validator installation)"
    echo "6. Запуск/остановка/перезапуск (Start/stop/restart)"
    echo "7. Проверить логи (Check Logs)"
    echo "8. Восстановить (Restore)"
    echo "9. Обновить (Update)"
    echo "10. Удалить ноду (Delete node)"
    echo "11. Выход (Exit)"
    echo ""
    read -p "Выберите опцию (Select option): " option

    case $option in
        1)
            #  PREPARATION
            show_orange "Начинаем подготовку (Starting preparation)..."
            sleep 1
            cd $HOME
            if sudo apt update && sudo apt upgrade -y && sudo apt-get install git -y && sudo apt install -y unzip nano; then
                sleep 1
                echo ""
                show_green "Успешно (Success)"
                echo ""
            else
                sleep 1
                echo ""
                show_red "Ошибка (Fail)"
                echo ""
            fi

            #  Python installation
            show_orange "Устанавливаем Python (Installing Python)..."
            sleep 1
            sudo apt install -y software-properties-common && sudo add-apt-repository ppa:deadsnakes/ppa && \
            sudo apt update && apt install python3.11 -y
            PYTHON_VERSION=$(python3.11 --version 2>&1)
            if [[ "$PYTHON_VERSION" == "Python 3.11.10" ]]; then
                sleep 1
                echo ""
                show_green "Python 3.11.10. Успешно (Success)"
                echo ""
            else
                sleep 1
                echo ""
                show_red "Ошибка (Fail)"
                echo ""
            fi

            #  POETRY installation
            show_orange "Устанавливаем Poetry (Installing Poetry)..."
            sleep 1
            sudo apt install python3-pip python3-venv curl -y
            curl -sSL https://install.python-poetry.org | python3 -
            sed -i '1i export PATH="/root/.local/bin:$PATH"' "$HOME/.bashrc"
            source $HOME/.bashrc

            POETRY_VERSION=$(poetry --version 2>&1)
            if [[ "$POETRY_VERSION" == Poetry* ]]; then
                sleep 1
                echo ""
                show_green "$POETRY_VERSION Успешно (Success)"
                echo ""
            else
                sleep 1
                echo ""
                show_red "Ошибка (Fail). Poetry не установлен (not installed)"
                echo ""
            fi

            #  Node.js and npm installation
            show_orange "Устанавливаем Node.js и npm (Installing Node.js and npm)..."
            sleep 1
            curl -fsSL https://fnm.vercel.app/install | bash
            source $HOME/.bashrc
            fnm use --install-if-missing 22
            sudo apt install npm
            NODE_VERSION=$(node -v 2>&1 | sed 's/v//')
            NPM_VERSION=$(npm -v 2>&1)

            MIN_NODE_VERSION="22.9.0"
            MIN_NPM_VERSION="10.8.3"

            if version_ge "$NODE_VERSION" "$MIN_NODE_VERSION" && version_ge "$NPM_VERSION" "$MIN_NPM_VERSION"; then
                sleep 1
                echo ""
                show_green "Успешно (Success)"
                echo ""
            else
                sleep 1
                echo ""
                show_red "Ошибка (Fail)"
                echo ""
            fi

            #  Installing dependencies
            show_orange "Устанавливаем зависимости (Installing dependencies)..."
            sleep 1
            apt-get install nodejs -y && npm install -g yarn
            if YARN_VERSION=$(yarn --version 2>&1); then
                sleep 1
                echo ""
                show_green "Yarn установлен (installed) Успешно (Success)"
                echo ""
            else
                sleep 1
                echo ""
                show_red "Ошибка (Fail)"
                echo ""
            fi
            echo ""
            show_green "--- ПОДГОТОВКА ЗАВЕРШЕНА. PREPARATION COMPLETED ---"
            echo ""
            ;;
        2)
            #  INSTALLATION

            show_orange "Начинаем установку (Starting installation)..."
            echo ""
            sleep 2

            show_orange "Клонируем репозиторий (Clone Repo)..."
            sleep 1
            if cd $HOME && git clone https://github.com/vana-com/vana-dlp-chatgpt.git && cd vana-dlp-chatgpt; then
                sleep 1
                echo ""
                show_green "Успешно (Success)"
                echo ""
            else
                sleep 1
                echo ""
                show_red "Ошибка (Fail)"
                echo ""
            fi

            show_orange "Создаем .env файл (Creating .env file)..."
            sleep 1
            if cp .env.example .env; then
                sleep 1
                echo ""
                show_green "Успешно (Success)"
                echo ""
            else
                sleep 1
                echo ""
                show_red "Ошибка (Fail)"
                echo ""
            fi

            show_orange "Устанавливаем зависимости и CLI (Installing dependencies and CLI)..."
            sleep 1
            if poetry install && pip install vana; then
                sleep 1
                echo ""
                show_green "Успешно (Success)"
                echo ""
            else
                sleep 1
                echo ""
                show_red "Ошибка (Fail)"
                echo ""
            fi

            echo ""
            show_green "--- НОДА УСТАНОВЛЕНА. NODE INSTALLED ---"
            echo ""
            ;;
        3)
            # WALLETS
            while true; do
                show_orange "Выберите (Choose):"
                echo "1. Создать (Create)"
                echo "2. Восстановить (Restore)"
                echo "3. Выход (Exit)"
                echo ""

                read -p "Введите номер опции (Enter option number): " option

                case $option in
                1)
                    # Create new wallets
                    show_orange "Создаем кошелеки (Creating wallets)..."
                    sleep 1
                    echo ""
                    show_orange "Придумайте пароль и запишите. Сохраните две мнемоник-фразы — Coldkey и Hotkey"
                    show_blue "-----------------------------------------------------------------------------"
                    show_orange "Come up with a password and write it down. Save two mnemonic phrases — Coldkey and Hotkey"
                    echo ""

                    show_green "Нажмите Enter, чтобы продолжить. Press Enter to proceed"
                    read

                    vanacli wallet create --wallet.name default --wallet.hotkey default

                    show_green "Нажмите Enter, чтобы продолжить. Press Enter to proceed"
                    read

                    show_orange "Экспортируем приватные ключи (Export private keys)..."
                    sleep 1
                    echo ""
                    show_blue "COLDKEY"
                    echo ""
                    vanacli wallet export_private_key
                    show_green "Нажмите Enter, чтобы продолжить. Press Enter to proceed"
                    read
                    show_blue "HOTKEY"
                    vanacli wallet export_private_key
                    echo ""
                    show_green "Нажмите Enter, чтобы продолжить. Press Enter to proceed"
                    read

                    # Generating keys
                    show_orange "Генерация ключей (Generating keys)..."
                    sleep 1
                    ./keygen.sh
                    ;;
                2)
                    # Restore Wallets
                    show_orange "Восстанавливаем кошельки (Restore wallets)..."
                    sleep 1
                    echo ""
                    read -p "Введите COLD private key: " COLD_PRIVATE_KEY
                    read -p "Введите HOT private key: " HOT_PRIVATE_KEY
                    vanacli w regen_coldkey --seed $COLD_PRIVATE_KEY
                    vanacli w regen_coldkey --seed $HOT_PRIVATE_KEY
                    echo ""
                    show_orange "-------------------------------------------------------------"
                    show_green "Теперь поместите файлы восстановления в папку vana-dlp-chatgpt"
                    show_green "Now place the recovery files in the vana-dlp-chatgpt folder."
                    show_orange "-------------------------------------------------------------"
                    ;;
                3)
                    break
                    ;;
                *)
                    show_orange "Неверный выбор (Invalid option)"
                    ;;
                esac
            done
            ;;
        4)
            #  DEPLOY TO MOKSHA
            show_orange "Начинаем деплой (Starting deploy)..."
            echo ""
            sleep 2

            show_orange "Останавливаем ноду (Stopping Node)..."
            sleep 1
            if sudo systemctl stop vana.service; then
                sleep 1
                echo ""
                show_green "Успешно (Success)"
                echo ""
            else
                sleep 1
                echo ""
                show_red "Ошибка (Fail)"
                echo ""
            fi

            show_orange "Удаляем папку (Deletting Dir)..."
            sleep 1
            if cd $HOME && rm -rvf vana-dlp-smart-contracts; then
                sleep 1
                echo ""
                show_green "Успешно (Success)"
                echo ""
            else
                sleep 1
                echo ""
                show_red "Ошибка (Fail)"
                echo ""
            fi

            show_orange "Создаем папку (Creating Dir)..."
            sleep 1
            if git clone https://github.com/Josephtran102/vana-dlp-smart-contracts && cd vana-dlp-smart-contracts; then
                sleep 1
                echo ""
                show_green "Успешно (Success)"
                echo ""
            else
                sleep 1
                echo ""
                show_red "Ошибка (Fail)"
                echo ""
            fi

            show_orange "Устанавливаем yarn (Installing Yarn)..."
            sleep 1
            if npm install -g yarn && yarn install && cp .env.example .env; then
                sleep 1
                echo ""
                show_green "Успешно (Success)"
                echo ""
            else
                sleep 1
                echo ""
                show_red "Ошибка (Fail)"
                echo ""
            fi

            # Enter data
            show_orange "Обновляем .env (Updating .env)..."
            echo ""
            sleep 1
            read -p "Введите (enter) private coldkey: " PRIVCOLDKEY
            read -p "Введите (enter) coldkey address: " ADDRESSCOLDKEY
            read -p "Введите (enter) DLP name: " DLPNAME
            read -p "Введите (enter) DLP Token Name: " DLPTOKENNAME
            read -p "Введите (enter) DLP Token Symbol: " DLPTOKENSYMBOL

            # Rewrite .env
            if sed -i "s/^DEPLOYER_PRIVATE_KEY=.*/DEPLOYER_PRIVATE_KEY=$PRIVCOLDKEY/" .env && \
                sed -i "s/^OWNER_ADDRESS=.*/OWNER_ADDRESS=$ADDRESSCOLDKEY/" .env && \
                sed -i "s/^DLP_NAME=.*/DLP_NAME=$DLPNAME/" .env && \
                sed -i "s/^DLP_TOKEN_NAME=.*/DLP_TOKEN_NAME=$DLPTOKENNAME/" .env && \
                sed -i "s/^DLP_TOKEN_SYMBOL=.*/DLP_TOKEN_SYMBOL=$DLPTOKENSYMBOL/" .env
            then
                sleep 1
                echo ""
                show_green "Файл .env обновлён. Успешно (Success)"
                echo ""
            else
                sleep 1
                echo ""
                show_red "Файл .env обновлён. Ошибка (Fail)"
                echo ""
            fi

            show_orange "Деплоим контракт (Deploying contract)..."
            sleep 1
            if npx hardhat deploy --network moksha --tags DLPDeploy; then
                sleep 1
                echo ""
                show_green "Успешно (Success)"
                echo ""
            else
                sleep 1
                echo ""
                show_red "Ошибка (Fail)"
                echo ""
            fi
            echo ""
            show_blue "СОХРАНИТЕ (SAVE) DataLiquidityPoolToken и DataLiquidityPool"
            echo ""
            ;;
        5)
            #  VALIDATOR INSTALLATION
            PUBLIC_KEY=$(cat /root/vana-dlp-chatgpt/public_key_base64.asc)
            show_orange "public_key_base64 = $PUBLIC_KEY"
            echo ""
            show_blue "СОХРАНИТЕ В НАДЕЖНОМ МЕСТЕ. STORE IN A SAFE PLACE"
            echo ""
            show_green "Нажмите Enter, чтобы продолжить. Press Enter to proceed"
            read

            show_orange "Редактируем .env (Editing .env)..."
            sleep 1
            echo ""
            ENV_FILE="$HOME/vana-dlp-chatgpt/.env"

            read -p "Введите (Enter) OpenAI API Key: " OPENAI_API_KEY
            read -p "Введите (Enter) DLP Smart Contract Address: " DATA_LIQUIDITY_POOL
            read -p "Введите (Enter) DLP Token Contract Address: " DATA_LIQUIDITY_POOL_TOKEN
            read -p "Введите (Enter) Public Key (base64): " PUBLIC_KEY

            if cat <<EOF > "$ENV_FILE"
# The network to use, currently Vana Moksha testnet
OD_CHAIN_NETWORK=moksha
OD_CHAIN_NETWORK_ENDPOINT=https://rpc.moksha.vana.org

# Optional: OpenAI API key for additional data quality check
OPENAI_API_KEY=$OPENAI_API_KEY

# Optional: Your own DLP smart contract address once deployed to the network, useful for local testing
DLP_MOKSHA_CONTRACT=$DATA_LIQUIDITY_POOL

# Optional: Your own DLP token contract address once deployed to the network, useful for local testing
DLP_TOKEN_MOKSHA_CONTRACT=$DATA_LIQUIDITY_POOL_TOKEN

# The private key for the DLP, follow "Generate validator encryption keys" section in the README
PRIVATE_FILE_ENCRYPTION_PUBLIC_KEY_BASE64=$PUBLIC_KEY
EOF
            then
                sleep 1
                echo ""
                show_green "Успешно (Success)"
                echo ""
            else
                sleep 1
                echo ""
                show_red "Ошибка (Fail)"
                echo ""
            fi
            echo ""
            show_blue "Отправьте 10 своих токенов на COLD И HOT кошельки"
            echo ""
            show_blue "Send 10 yours tokens to COLD and HOT wallets"
            echo ""
            show_green "Нажмите Enter, чтобы продолжить. Press Enter to proceed"
            read

            show_orange "Регистрируем валидатора (Validator registration)..."
            sleep 1
            if cd &HOME/vana-dlp-chatgpt/ && ./vanacli dlp register_validator --stake_amount 10; then
                sleep 1
                echo ""
                show_green "Успешно (Success)"
                echo ""
            else
                sleep 1
                echo ""
                show_red "Ошибка (Fail)"
                echo ""
            fi
            echo ""

            show_orange "Подтверждаем валидатора (Approving Validator)..."
            sleep 1
            echo ""
            read -p "Введите (Enter) HOT KEY ADDRESS: " HOTKEY_ADDRESS
            if cd &HOME/vana-dlp-chatgpt/ && ./vanacli dlp approve_validator --validator_address=$HOTKEY_ADDRESS; then
                sleep 1
                echo ""
                show_green "Успешно (Success)"
                echo ""
            else
                sleep 1
                echo ""
                show_red "Ошибка (Fail)"
                echo ""
            fi

            show_orange "Создаем сервис (Creating Service)..."
            sleep 1
            cd $HOME
            POETRY_PATH=$(which poetry)
            if sudo tee /etc/systemd/system/vana.service << EOF
[Unit]
Description=Vana Validator Service
After=network.target

[Service]
Type=simple
User=root
WorkingDirectory=/root/vana-dlp-chatgpt
ExecStart=$POETRY_PATH run python -m chatgpt.nodes.validator
Restart=on-failure
RestartSec=10
Environment=PATH=/root/.local/bin:/usr/local/bin:/usr/bin:/bin:/root/vana-dlp-chatgpt/myenv/bin
Environment=PYTHONPATH=/root/vana-dlp-chatgpt

[Install]
WantedBy=multi-user.target
EOF
            then
                sleep 1
                echo ""
                show_green "Успешно (Success)"
                echo ""
            else
                sleep 1
                echo ""
                show_red "Ошибка (Fail)"
                echo ""
            fi

            show_orange "Запускаем сервис (Starting Service)..."
            sleep 1
            if sudo systemctl daemon-reload && sudo systemctl enable vana.service && sudo systemctl start vana.service; then
                sleep 1
                echo ""
                show_green "Успешно (Success)"
                echo ""
            else
                sleep 1
                echo ""
                show_red "Ошибка (Fail)"
                echo ""
            fi

            SERVICE_STATUS=$(sudo systemctl is-active vana.service)
            if [[ "$SERVICE_STATUS" == "active" ]]; then
                show_green "НОДА АКТИВНА И РАБОТАЕТ. NODE IS ACTIVE AND OPERATING"
            else
                show_red "НЕ УДАЛОСЬ ЗАПУСТИТЬ НОДУ. COULDN'T START THE NODE"
            fi
            ;;
        6)
            # Operating
            while true; do
                show_orange "Выберите (Choose):"
                echo "1. Запустить (Start)"
                echo "2. Остановить (Stop)"
                echo "3. Перезапустить (Restart)"
                echo "4. Выход (Exit)"
                echo ""

                read -p "Введите номер опции (Enter option number): " option

                case $option in
                    1)
                        show_orange "Запускаем (Starting) vana.service..."
                        sleep 1
                        if sudo systemctl start vana.service; then
                            sleep 1
                            echo ""
                            show_green "Успешно (Success)"
                            echo ""
                        else
                            sleep 1
                            echo ""
                            show_red "Ошибка (Fail)"
                            echo ""
                        fi
                        ;;
                    2)
                        show_orange "Останавливаем (Stopping) vana.service..."
                        sleep 1
                        if sudo systemctl stop vana.service; then
                            sleep 1
                            echo ""
                            show_green "Успешно (Success)"
                            echo ""
                        else
                            sleep 1
                            echo ""
                            show_red "Ошибка (Fail)"
                            echo ""
                        fi
                        ;;
                    3)
                        show_orange "Перезапускаем (Restaring) vana.service..."
                        sleep 1
                        if sudo systemctl restart vana.service; then
                            sleep 1
                            echo ""
                            show_green "Успешно (Success)"
                            echo ""
                        else
                            sleep 1
                            echo ""
                            show_red "Ошибка (Fail)"
                            echo ""
                        fi
                        ;;
                    4)
                        break
                        ;;
                    *)
                        show_orange "Неверный выбор (Invalid option)"
                        ;;
                esac
                echo ""
            done
            ;;
        7)
            # Check logs
            sudo journalctl -u vana.service -f
            ;;
        8)
            #Restore
            echo ""
            show_orange "--- TBA. ЗАРЕЗИРВИРОВАНО ---"
            echo ""
            ;;
        9)
            # Update
            echo ""
            show_orange "--- TBA. ЗАРЕЗИРВИРОВАНО ---"
            echo ""
            ;;
        10)
            # Deleting node
            show_orange "Удаляем (Deleting) node..."
            sleep 1
            echo ""
            show_red "_____________ !!!WARNING!!! ________________"
            echo ""
            show_orange "УБЕДИТЕСЬ ЧТО ВЫ СОХРАНИЛИ ДАННЫЕ ДЛЯ ВОССТАНОВЛЕНИЯ"
            echo ""
            show_orange "MAKE SURE YOU HAVE SAVED THE RECOVERY DATA"
            echo ""
            show_red "_____________ !!!WARNING!!! ________________"

            read -p "Удалить ноду? Delete node? (yes/no): " option

            case "$option" in
                yes|y|Y|Yes|YES)
                    show_orange "Удаление (Deleting)..."
                    sleep 1
                    sudo systemctl stop vana.service
                    sudo systemctl disable vana.service
                    sudo systemctl daemon-reload
                    rm -rvf $HOME/.vana
                    rm -rvf $HOME/vana-dlp-chatgpt
                    rm -rvf $HOME/vana-dlp-smart-contracts
                    show_green "--- НОДА УДАЛЕНА. NODE DELETED. ---"
                    ;;
                no|n|N|No|NO)
                    show_orange "Отмена (Cancel)"
                    sleep 2
                    break
                    ;;
                *)
                    show_orange " Введите (Enter) 'yes' или 'no'."
                    ;;
            esac
            ;;
        11)
            # Stop script and exit
            show_red "Скрипт остановлен (Script stopped)"
            echo ""
            exit 0
            ;;
        *)
            # incorrect options handling
            echo ""
            echo -e "\e[31mНеверная опция\e[0m. Пожалуйста, выберите из тех, что есть."
            echo ""
            echo -e "\e[31mInvalid option.\e[0m Please choose from the available options."
            echo ""
            ;;
    esac
done
