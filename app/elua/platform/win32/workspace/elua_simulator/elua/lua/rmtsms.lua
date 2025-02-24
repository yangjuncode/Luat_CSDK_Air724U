
-- ����Զ��ң�ز���
require"sys"
require"common"
require"sms"
require"nvm"
module(...,package.seeall)

local function replypos(num)
	sms.send(num,common.binstohexs(common.gb2312toucs2be(gps.googlepos())))
end

local function procsms(num,data)
	if string.sub(num,1,3) == "+86" then
		num = string.sub(num,4,-1)
	end

	local code,op = string.match(common.ucs2betogb2312(common.hexstobins((data))),"(%d+)(.*)$")

	if code and op and nvm.get("opcode") == code then
		local opfnc
		local admin = nvm.isadmin(num)
		local alarmnum = nvm.isalarmnum(num)

		if op == "ֹͣ����" and alarmnum ==  true then opfnc = defense.alarmstop
		elseif op == "����" and admin == true then opfnc = defense.alert
		elseif op == "����" and admin == true then opfnc = defense.disarm
		elseif op == "������" and admin == true then replypos(num) return --��ѯλ��
		else print("num invalid operation",num,string.byte(op,1,-1)) return
		end

		sms.send(num,common.binstohexs(common.gb2312toucs2be(op..(opfnc("sms") == true and "�ɹ�" or "ʧ��"))))
	else
		print("invalid data",data)
	end
end

local function newmsg(pos)
	sms.read(pos)
end

local function readcnf(result,num,data,pos)
	procsms(num,data)
	-- ɾ���¶���
	sms.delete(pos)
end

local smsapp =
{
	SMS_NEW_MSG_IND = newmsg,
	SMS_READ_CNF = readcnf,
}

sys.regapp(smsapp)
