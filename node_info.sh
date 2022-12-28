#!/bin/bash
# Default variables
port="9005"
language="EN"
raw_output="false"

# Options
. <(wget -qO- https://raw.githubusercontent.com/CHINGIZ8/minima/main/colors.sh) --
option_value(){ echo $1 | sed -e 's%^--[^=]*=%%g; s%^-[^=]*=%%g'; }
while test $# -gt 0; do
	case "$1" in
	-h|--help)

		return 0 2>/dev/null; exit 0
		;;
	-p*|--port*)
		if ! grep -q "=" <<< $1; then shift; fi
		port=`option_value $1`
		shift
		;;
	-l*|--language*)
		if ! grep -q "=" <<< $1; then shift; fi
		language=`option_value $1`
		shift
		;;
	-ro|--raw-output)
		raw_output="true"
		shift
		;;
	*|--)
		break
		;;
	esac
done

# Functions
printf_n(){ printf "$1\n" "${@:2}"; }
main() {
	sudo apt install jq -y &>/dev/null
	# Texts
	if [ "$language" = "RU" ]; then

		local t_re="\n${C_R}Либо не зарегистрирована нода, либо некорректно работает RPC, который не починить!${RES}\n"
		local t_nv="\nВерсия ноды:            ${C_LGn}%s${RES}"
		local t_lb="Текущий блок:         ${C_LGn}%s${RES}\n"
		
		local t_ni="\nID ноды:                ${C_LGn}%s${RES}"
		local t_rc="Реферальный код:        ${C_LGn}%s${RES}"
		local t_lp="Последний сигнал:       ${C_LGn}%s${RES} (UTC)"
		
		local t_r="\n\n\tНаграды\n"
		local t_af="Нода после форка:       ${C_LGn}%d${RES}"
		local t_bf="Нода до форка:          ${C_LGn}%d${RES}"
		local t_cc="Вклад в сообщество:     ${C_LGn}%d${RES}"
		local t_ir="Приглашение рефералов:  ${C_LGn}%d${RES}"
		

	else

	fi

	# Actions
	local local_rpc="http://localhost:${port}/"
	local status=`wget -qO- "${local_rpc}status"`
	local incentivecash=`wget -qO- "${local_rpc}incentivecash"`
	
	local node_version=`jq -r ".response.version" <<< "$status"`
	local latest_block_height=`jq -r ".response.chain.block" <<< "$status"`
	
	local node_id=`jq -r ".response.uid" <<< "$incentivecash"`
	if [ -n "$node_id" ]; then
		local node_id_hidden=`printf "$node_id" | sed 's%.*-.*-.*- *%...-%'`
		local referral_code=`jq -r ".response.details.inviteCode" <<< "$incentivecash"`
		local last_ping=`jq -r ".response.details.lastPing" <<< "$incentivecash"`
		local last_ping_unix=`date --date "$last_ping" +"%s"`
		local last_ping_human=`date --date "$last_ping" +"%d.%m.%y %H:%M" -u`
		
		local after_fork=`jq -r ".response.details.rewards.dailyRewards" <<< "$incentivecash"`
		local before_fork=`jq -r ".response.details.rewards.previousRewards" <<< "$incentivecash"`
		local community_contribution=`jq -r ".response.details.rewards.communityRewards" <<< "$incentivecash"`
		local inviting_referrals=`jq -r ".response.details.rewards.inviterRewards" <<< "$incentivecash"`
	fi
	
	# Output
	if [ "$raw_output" = "true" ]; then
		printf_n '{"node_version": "%s", "latest_block_height": %d, "node_id": "%s", "referral_code": "%s", "last_ping": %d, "rewards": {"after_fork": %d, "before_fork": %d, "community_contribution": %d, "inviting_referrals": %d}}' \
"$node_version" \
"$latest_block_height" \
"$node_id" \
"$referral_code" \
"$last_ping_unix" \
"$after_fork" \
"$before_fork" \
"$community_contribution" \
"$inviting_referrals" 2>/dev/null
	else
		printf_n "$t_nv" "$node_version"
		printf_n "$t_lb" "$latest_block_height"
		
		if [ ! -n "$node_id" ]; then
			printf_n "$t_re"
		else
			printf_n "$t_ni" "$node_id_hidden"
			printf_n "$t_rc" "$referral_code"
			printf_n "$t_lp" "$last_ping_human"
			
			printf_n "$t_r"
			printf_n "$t_af" "$after_fork"
			printf_n "$t_bf" "$before_fork"
			printf_n "$t_cc" "$community_contribution"
			printf_n "$t_ir" "$inviting_referrals"
			printf_n
		fi
	fi
}

main
