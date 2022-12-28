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
		local t_lb="Последний блок:         ${C_LGn}%s${RES}\n"
		
		
		
	# Send Pull request with new texts to add a language - https://github.com/CHINGIZ8/minima/main/node_info.sh
	#elif [ "$language" = ".." ]; then
	else
		#local t_re="\n${C_R}You haven't registered the node!${RES}

#${C_LGn}To register you need to${RES}:
#1) Go to the site: https://incentivecash.minima.global/
#2) Log in
#3) Copy the node ID
#4) Execute the command below and enter the node ID
#. <(wget -qO- https://raw.githubusercontent.com/CHINGIZ8/minima/main/multi_tool.sh) -rg\n"
		local t_re="\n${C_R}Either the node is not registered, or the RPC does not work correctly, which cannot be fixed!${RES}\n"
		local t_nv="\nNode version:            ${C_LGn}%s${RES}"
		local t_lb="Latest block height:     ${C_LGn}%s${RES}\n"

	fi

	# Actions
	local local_rpc="http://localhost:${port}/"
	local status=`wget -qO- "${local_rpc}status"`
	local incentivecash=`wget -qO- "${local_rpc}incentivecash"`
	
	local node_version=`jq -r ".response.version" <<< "$status"`
	local latest_block_height=`jq -r ".response.chain.block" <<< "$status"`
	
	local node_id=`jq -r ".response.uid" <<< "$incentivecash"`
	if [ -n "$node_id" ]; then
		
		
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
