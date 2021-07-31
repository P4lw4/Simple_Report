/*
Simple-Report System

Credits: SA-MP Team Past - Recent - Future, Zeex, Y_Less, etc.
Author: Palwa
*/
#include <a_samp>
#include <zcmd>
#include <foreach>

#define MAX_REPORTS 30
#define MAX_ASKS 30

// Report Data
enum E_REPORT
{
	REPORT_PLAYERID,
	REPORT_PLAYER_NAME[MAX_PLAYER_NAME],
	REPORT_TEXT[50]
}
new g_report[MAX_REPORTS][E_REPORT];
new Iterator: Reports<MAX_REPORTS>;

// Ask Data
enum E_ASK
{
	ASK_PLAYERID,
	ASK_PLAYER_NAME[MAX_PLAYER_NAME],
	ASK_TEXT[50]
}
new g_ask[MAX_ASKS][E_ASK];
new Iterator: Asks<MAX_ASKS>;

// Player variable
new g_player_listitem[MAX_PLAYERS][50];
new g_player_name[MAX_PLAYERS][MAX_PLAYER_NAME];

// Callback
public OnPlayerUpdate(playerid)
{
	GetPlayerName(playerid, g_player_name[playerid], MAX_PLAYER_NAME);
	return 1;
}

public OnPlayerDisconnect(playerid, reason)
{
	if(IsPlayerHasReport(playerid))
	{
	    foreach(new id : Reports)
	    {
	        if(g_report[id][REPORT_PLAYERID] != playerid) continue;
	        
			ClearReport(id);
	    }
	}
	return 1;
}

public OnDialogResponse(playerid, dialogid, response, listitem, inputtext[])
{
	if(IsPlayerConnected(playerid))
	{
	    switch(dialogid)
	    {
	        case 2344:
	        {
	            new
					id = g_player_listitem[playerid][listitem],
					otherid = g_report[id][REPORT_PLAYERID];

	            if(response)
	            {
		            if(!IsPlayerConnected(otherid))
		                return ClearReport(id);

					ShowPlayerDialog(playerid, 2346, DIALOG_STYLE_INPUT, "Panel Keluhan",
					"Apa yang anda ingin lakukan pada keluhan ini?\n"\
					"Jika anda ingin menolaknya anda bisa mengisi alasan pada box dibawah\n"\
					"Namun, jika anda ingin menerimanya. Anda hanya perlu melakukan klik pada tombol terima", "Terima", "Tolak");

					SetPVarInt(playerid, "TEMP_LISTITEM", id);
				}
	        }
	        case 2345:
	        {
	            new
				    id = g_player_listitem[playerid][listitem],
			     	otherid = g_ask[id][ASK_PLAYERID];

	            if(response)
	            {
		            if(!IsPlayerConnected(otherid))
		                return ClearAsk(id);

					ShowPlayerDialog(playerid, 2347, DIALOG_STYLE_INPUT, "Panel Pertanyaan",
					"Apa yang anda ingin lakukan pada pertanyaan ini?\n"\
					"Jika anda ingin tidak ingin menjawab anda bisa mengisi alasan pada box dibawah\n"\
					"Namun, jika anda ingin menjawabnya. Anda perlu mengisi jawaban pada box tersebut", "Jawab", "Tolak");

					SetPVarInt(playerid, "TEMP_LISTITEM", id);
				}
	        }
	        case 2346:
	        {
	            new id = GetPVarInt(playerid, "TEMP_LISTITEM");
	            new string[144];
	            
	            if(Iter_Contains(Reports, id))
	            {
		            if(response){
						format(string, sizeof(string), "{FF0000}[REPORT] {FFFFFF}Admin {FFFF00}%s {FFFFFF}menerima laporan anda", g_player_name[playerid]);
		                SendClientMessage(g_report[id][REPORT_PLAYERID], -1, string);

		                format(string, sizeof(string), "{FF0000}[REPORT] {FFFFFF}Anda menerima laporan dari {FFFF00}%s", g_report[id][REPORT_PLAYER_NAME]);
		                SendClientMessage(playerid, -1, string);
		            }
		            else
		            {
		                format(string, sizeof(string), "{FF0000}[REPORT] {FFFFFF}Admin {FFFF00}%s {FFFFFF}menolak laporan anda | %s", g_player_name[playerid], inputtext);
		                SendClientMessage(g_report[id][REPORT_PLAYERID], -1, string);

		                format(string, sizeof(string), "{FF0000}[REPORT] {FFFFFF}Anda menerima laporan dari {FFFF00}%s", g_report[id][REPORT_PLAYER_NAME]);
		                SendClientMessage(playerid, -1, string);
		            }
		        }
		        ClearReport(id);
		        DeletePVar(playerid, "TEMP_LISTITEM");
	        }
	        case 2437:
	        {
	            new id = GetPVarInt(playerid, "TEMP_LISTITEM");
	            new string[144];

				if(strlen(inputtext))
				{
		            if(Iter_Contains(Asks, id))
		            {
			            if(response){
							format(string, sizeof(string), "{00FF00}[ANSWER] {FFFFFF}Admin %s | %s", g_player_name[playerid], inputtext);
			                SendClientMessage(g_ask[id][ASK_PLAYERID], -1, string);

			                format(string, sizeof(string), "{00FF00}[ASK] {FFFFFF}Anda menerima laporan dari {FFFF00}%s", g_ask[id][ASK_PLAYER_NAME]);
			                SendClientMessage(playerid, -1, string);
			            }
			            else
			            {
			                format(string, sizeof(string), "{00FF00}[ANSWER] {FFFFFF}Admin {FFFF00}%s {FFFFFF}menolak pertanyaan anda | %s", g_player_name[playerid], inputtext);
			                SendClientMessage(g_ask[id][ASK_PLAYERID], -1, string);

			                format(string, sizeof(string), "{00FF00}[ASK] {FFFFFF}Anda menerima laporan dari {FFFF00}%s", g_ask[id][ASK_PLAYER_NAME]);
			                SendClientMessage(playerid, -1, string);
			            }
			        }
				}
				
		        ClearReport(id);
		        DeletePVar(playerid, "TEMP_LISTITEM");
	        }
	    }
	}
	
	for(new i; i < 50; i++){
	    g_player_listitem[playerid][i] = -1;
	}
	return 1;
}
// Commands
CMD:report(playerid, params[])
{
	new id = Iter_Free(Reports);
	
	if(id == -1)
	    return SendClientMessage(playerid, 0xCECECEFF, "Antrian laporan sedang penuh, coba lagi nanti!");
	    
	if(strlen(params) < 10)
	    return SendClientMessage(playerid, 0xCECECEFF, "Teks laporan minimal adalah 10 karakter");
	    
	if(IsPlayerHasReport(playerid))
	    return SendClientMessage(playerid, 0xCECECEFF, "Anda hanya bisa mengajukan 1 keluhan. Anda bisa kembali bertanya setelah mendapat jawaban");

	g_report[id][REPORT_PLAYERID] = playerid;
	format(g_report[id][REPORT_PLAYER_NAME], MAX_PLAYER_NAME, "%s", g_player_name[playerid]);
	format(g_report[id][REPORT_TEXT], 50, "%s", params);
	
	SendClientMessage(playerid, -1, "{FF0000}[REPORT] {FFFFFF}Anda berhasil mengirimkan keluhan kepada administrasi");
	SendMessageToAdmins("{FF0000}[REPORT] {FFFFFF}Sebuah pemain mengajukan keluhan, gunakan {FFFF00}/reports");
	
	Iter_Add(Reports, id);
	return 1;
}

CMD:ask(playerid, params[])
{
	new id = Iter_Free(Asks);

	if(id == -1)
	    return SendClientMessage(playerid, 0xCECECEFF, "Antrian pertanyaan sedang penuh, coba lagi nanti!");

	if(strlen(params) < 10)
	    return SendClientMessage(playerid, 0xCECECEFF, "Teks pertanyaan minimal adalah 10 karakter");

	if(IsPlayerHasAsk(playerid))
	    return SendClientMessage(playerid, 0xCECECEFF, "Anda hanya bisa mengajukan 1 pertanyaan. Anda bisa kembali bertanya setelah mendapat jawaban");
	    
	g_ask[id][ASK_PLAYERID] = playerid;
	format(g_ask[id][ASK_PLAYER_NAME], MAX_PLAYER_NAME, "%s", g_player_name[playerid]);
	format(g_ask[id][ASK_TEXT], 50, "%s", params);

	SendClientMessage(playerid, -1, "{00FF00}[ASK] {FFFFFF}Anda berhasil membuat pertanyaan kepada administrasi");
	SendMessageToAdmins("{00FF00}[ASK] {FFFFFF}Sebuah pemain mengajukan pertanyaan, gunakan {FFFF00}/asks");
	
	Iter_Add(Asks, id);
	return 1;
}

CMD:reports(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
		return SendClientMessage(playerid, 0xCECECEFF, "Anda tidak punya izin untuk menggunakan command ini!");
		
	if(GetReportTotal() == -1)
	    return SendClientMessage(playerid, 0xCECECEFF, "Tidak ada laporan keluhan saat ini");
	
	new temp_string[75], dialog[300];
	new count;

	// Format the dialog head first
	format(temp_string, 75, "Player\tReport Text\n");
	
	foreach(new id : Reports)
	{
	    format(temp_string, 75, "%s%s (%d)\t%s", temp_string, g_report[id][REPORT_PLAYER_NAME], g_report[id][REPORT_PLAYERID], g_report[id][REPORT_TEXT]);
	    strcat(dialog, temp_string);
	    g_player_listitem[playerid][count] = g_report[id][REPORT_PLAYERID];
	    count++;
	}
	
	ShowPlayerDialog(playerid, 2344, DIALOG_STYLE_TABLIST_HEADERS, "Daftar keluhan", dialog, "Pilih", "Cancel");
	return 1;
}

CMD:asks(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
		return SendClientMessage(playerid, 0xCECECEFF, "Anda tidak punya izin untuk menggunakan command ini!");

	if(GetAskTotal() == -1)
	    return SendClientMessage(playerid, 0xCECECEFF, "Tidak ada pertanyaan saat ini");

	new temp_string[75], dialog[300];
	new count;

	// Format the dialog head first
	format(temp_string, 75, "Player\tQuestion\n");

	foreach(new id : Reports)
	{
	    format(temp_string, 75, "%s%s (%d)\t%s", temp_string, g_ask[id][ASK_PLAYER_NAME], g_ask[id][ASK_PLAYERID], g_ask[id][ASK_TEXT]);
	    strcat(dialog, temp_string);
	    g_player_listitem[playerid][count] = g_report[id][REPORT_PLAYERID];
	    count++;
	}

	ShowPlayerDialog(playerid, 2345, DIALOG_STYLE_TABLIST_HEADERS, "Daftar Pertanyaan", dialog, "Pilih", "Cancel");
	return 1;
}

CMD:clearreport(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
		return SendClientMessage(playerid, 0xCECECEFF, "Anda tidak punya izin untuk menggunakan command ini!");

	if(GetReportTotal() == -1)
	    return SendClientMessage(playerid, 0xCECECEFF, "Tidak ada laporan keluhan saat ini");
	    
	foreach(new i : Reports){
		ClearReport(i);
	}
	SendClientMessage(playerid, -1, "{FF0000}[REPORT] {FFFFFF}Seluruh laporan telah dibersihkan");
	return 1;
}

CMD:clearask(playerid, params[])
{
	if(!IsPlayerAdmin(playerid))
		return SendClientMessage(playerid, 0xCECECEFF, "Anda tidak punya izin untuk menggunakan command ini!");

	if(GetAskTotal() == -1)
	    return SendClientMessage(playerid, 0xCECECEFF, "Tidak ada pertanyaan saat ini");

	foreach(new i : Asks){
		ClearAsk(i);
	}
	SendClientMessage(playerid, -1, "{00FF00}[ASK] {FFFFFF}Seluruh pertanyaan telah dibersihkan");
	return 1;
}

// Custom Functions
GetReportTotal(){
	new count = -1;
	
	foreach(new i : Reports){
	    count++;
	}
	return count;
}

GetAskTotal(){
	new count = -1;

	foreach(new i : Asks){
	    count++;
	}
	return count;
}

ClearReport(id)
{
	if(Iter_Contains(Reports, id))
	{
		g_report[id][REPORT_PLAYERID] = INVALID_PLAYER_ID;
		format(g_report[id][REPORT_PLAYER_NAME], MAX_PLAYER_NAME , "");
		format(g_report[id][REPORT_TEXT], 50, "");
		Iter_Remove(Reports, id);
		return 1;
	}
	return 0;
}

ClearAsk(id)
{
	if(Iter_Contains(Asks, id))
	{
		g_ask[id][ASK_PLAYERID] = INVALID_PLAYER_ID;
		format(g_ask[id][ASK_PLAYER_NAME], MAX_PLAYER_NAME , "");
		format(g_ask[id][ASK_TEXT], 50, "");
		Iter_Remove(Asks, id);
		return 1;
	}
	return 0;
}

IsPlayerHasReport(playerid)
{
	foreach(new i : Reports)
	{
	    if(g_report[i][REPORT_PLAYERID] == playerid)
			return 1;
	}
	return 0;
}

IsPlayerHasAsk(playerid)
{
	foreach(new i : Asks)
	{
	    if(g_ask[i][ASK_PLAYERID] == playerid)
			return 1;
	}
	return 0;
}

SendMessageToAdmins(text[])
{
	foreach(new i : Player)
	{
	    if(!IsPlayerAdmin(i)) continue;
	    
	    SendClientMessage(i, -1, text);
	}
	return 1;
}
