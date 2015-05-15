////// CONFIGURATION MISSION_TOOLKIT OFCRA

// gears_infantry: �quipement automatis� des infanteries
OFCRA_GI_UNITES_CIBLES = "HUMAINS+IA";			// parmi {HUMAINS+IA|HUMAINS}
OFCRA_GI_LISTE_INFANTERIE_EXCEPTIONS = ["ex001","ex002","ex003","ex004","ex005","ex006","ex007"];		// tableau de noms d'unit�s entre-guillemets � ne pas �quiper, ex: ["nom1", "nom2"]
OFCRA_GI_TENUES_BLUEFOR = "UCP";			// parmi {UCP|OCP|SOC|MARPAT_WOOD|MARPAT_DESERT}
OFCRA_GI_TENUES_REDFOR = "VDV";				// parmi {VDV|VDV-M|MSV_DIGITAL|MSV_FLORA|M88}

// gears_vehicles: �quipement automatis� des v�hicules
OFCRA_GV_LISTE_VEHICULES_EXCEPTIONS = [];		// tableau de noms d'unit�s v�hicules entre-guillemets � ne pas �quiper le cargo, ex: ["nom1", "nom2"]

// score_board: d�finition du tableau des scores et des objectifs
OFCRA_SC_DUREE_MISSION = [0, 30, 0]; // [heures, minutes, secondes], ex: [1,30,15] pour une dur�e d' 1h30min15s avant l'affichage du tableau des scores
//[] call createObjective;




////// CONFIGURATION ADDONS EXTERNES

// TAW_VIEWDISTANCE
tawvd_disablenone = true;
tawvd_maxRange = 6000;

// TASK FORCE ARROWHEAD RADIO
TF_no_auto_long_range_radio = 1;



//// EXECUTION MISSION_TOOLKIT OFCRA
// si vous commentez la ligne ci-dessous, le mission_toolkit sera inactif
execVM "OFCRA\ofcra.sqf"; 

doc = missionNamespace getVariable ["docs" , objNull];
ofrca_fn_took = {
	 hint format ["%1 !", _this select 3];
	 doc removeAction doc_action;
	 hideObjectGlobal doc;
	 [] call ofcra_scoreboard_display;
};

doc_action = doc addAction["<t color='#FF0000'>Prendre le dossier</t>", { call ofrca_fn_took; }, side player];
