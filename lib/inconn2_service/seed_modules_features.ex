defmodule Inconn2Service.CreateModuleFeatureRoles do
  alias Inconn2Service.Staff

  def seed_features(prefix) do

    md1 = %{"name" => "Licensee management", "code" => "LIMN"}
    md2 = %{"name" => "Asset management", "code" => "ASMN"}
    md3 = %{"name" => "Workflow management", "code" => "WFMN"}
    md4 = %{"name" => "People management", "code" => "PLMN"}
    md5 = %{"name" => "Inventory management", "code" => "INMN"}
    md6 = %{"name" => "Ticketing Management", "code" => "TIMN"}
    md7 = %{"name" => "Alerts and Notifications", "code" => "ANDN"}
    md8 = %{"name" => "Reports and Dashboards", "code" => "RNDD"}

    {:ok, md1c} = Staff.create_module(md1, prefix)
    {:ok, md2c} = Staff.create_module(md2, prefix)
    {:ok, md3c} = Staff.create_module(md3, prefix)
    {:ok, md4c} = Staff.create_module(md4, prefix)
    {:ok, md5c} = Staff.create_module(md5, prefix)
    {:ok, md6c} = Staff.create_module(md6, prefix)
    {:ok, md7c} = Staff.create_module(md7, prefix)
    {:ok, md8c} = Staff.create_module(md8, prefix)

    ft1 = %{"name" => "Create License", "code" => "CRLI", "module_id" => md1c.id}
    ft2 = %{"name" => "Edit License", "code" => "EDLI", "module_id" => md1c.id}
    ft3 = %{"name" => "Delete License", "code" => "DLLI", "module_id" => md1c.id}
    ft4 = %{"name" => "List view License", "code" => "LVLI", "module_id" => md1c.id}
    ft5 = %{"name" => "View License", "code" => "VILI", "module_id" => md1c.id}
    ft6 = %{"name" => "Import License", "code" => "IMLI", "module_id" => md1c.id}
    ft7 = %{"name" => "Create party", "code" => "CRPT", "module_id" => md1c.id}
    ft8 = %{"name" => "Edit party", "code" => "EDPT", "module_id" => md1c.id}
    ft9 = %{"name" => "Delete party", "code" => "DLPT", "module_id" => md1c.id}
    ft10 = %{"name" => "List view party", "code" => "LVPT", "module_id" => md1c.id}
    ft11 = %{"name" => "View party", "code" => "VIPT", "module_id" => md1c.id}
    ft12 = %{"name" => "Import party", "code" => "IMPT", "module_id" => md1c.id}
    ft13 = %{"name" => "Create Site", "code" => "CRSI", "module_id" => md1c.id}
    ft14 = %{"name" => "Edit Site", "code" => "EDSI", "module_id" => md1c.id}
    ft15 = %{"name" => "Delete Site", "code" => "DLSI", "module_id" => md1c.id}
    ft16 = %{"name" => "View site", "code" => "VISI", "module_id" => md1c.id}

    {:ok, ft1c} = Staff.create_feature(ft1, prefix)
    {:ok, ft2c} = Staff.create_feature(ft2, prefix)
    {:ok, ft3c} = Staff.create_feature(ft3, prefix)
    {:ok, ft4c} = Staff.create_feature(ft4, prefix)
    {:ok, ft5c} = Staff.create_feature(ft5, prefix)
    {:ok, ft6c} = Staff.create_feature(ft6, prefix)
    {:ok, ft7c} = Staff.create_feature(ft7, prefix)
    {:ok, ft8c} = Staff.create_feature(ft8, prefix)
    {:ok, ft9c} = Staff.create_feature(ft9, prefix)
    {:ok, ft10c} = Staff.create_feature(ft10, prefix)
    {:ok, ft11c} = Staff.create_feature(ft11, prefix)
    {:ok, ft12c} = Staff.create_feature(ft12, prefix)
    {:ok, ft13c} = Staff.create_feature(ft13, prefix)
    {:ok, ft14c} = Staff.create_feature(ft14, prefix)
    {:ok, ft15c} = Staff.create_feature(ft15, prefix)
    {:ok, ft16c} = Staff.create_feature(ft16, prefix)

    ft17 = %{"name" => "Create Equipment ", "code" => "CREQ", "module_id" => md2c.id}
    ft18 = %{"name" => "Edit Equipment", "code" => "EDEQ", "module_id" => md2c.id}
    ft19 = %{"name" => "Delete Equipment", "code" => "DLEQ", "module_id" => md2c.id}
    ft20 = %{"name" => "List view Equipment", "code" => "LVEQ", "module_id" => md2c.id}
    ft21 = %{"name" => "View Equipment", "code" => "VIEQ", "module_id" => md2c.id}
    ft22 = %{"name" => "Import Equipment", "code" => "IMEQ", "module_id" => md2c.id}
    ft23 = %{"name" => "Create Location", "code" => "CRLO", "module_id" => md2c.id}
    ft24 = %{"name" => "Edit Location", "code" => "EDLO", "module_id" => md2c.id}
    ft25 = %{"name" => "Delete Location", "code" => "DLLO", "module_id" => md2c.id}
    ft26 = %{"name" => "List view of location", "code" => "LVLO", "module_id" => md2c.id}
    ft27 = %{"name" => "View location", "code" => "VILO", "module_id" => md2c.id}
    ft28 = %{"name" => "Import location", "code" => "IMLO", "module_id" => md2c.id}
    ft29 = %{"name" => "Create parent-child relationship", "code" => "CRPC", "module_id" => md2c.id}
    ft30 = %{"name" => "Edit parent-child relationship", "code" => "EDPC", "module_id" => md2c.id}
    ft31 = %{"name" => "Delete parent-child relationship", "code" => "DLPC", "module_id" => md2c.id}
    ft32 = %{"name" => "View parent-child relationship", "code" => "VIPC", "module_id" => md2c.id}
    ft33 = %{"name" => "Import parent-child relationship", "code" => "IMPC", "module_id" => md2c.id}

    {:ok, ft17c} = Staff.create_feature(ft17, prefix)
    {:ok, ft18c} = Staff.create_feature(ft18, prefix)
    {:ok, ft19c} = Staff.create_feature(ft19, prefix)
    {:ok, ft20c} = Staff.create_feature(ft20, prefix)
    {:ok, ft21c} = Staff.create_feature(ft21, prefix)
    {:ok, ft22c} = Staff.create_feature(ft22, prefix)
    {:ok, ft23c} = Staff.create_feature(ft23, prefix)
    {:ok, ft24c} = Staff.create_feature(ft24, prefix)
    {:ok, ft25c} = Staff.create_feature(ft25, prefix)
    {:ok, ft26c} = Staff.create_feature(ft26, prefix)
    {:ok, ft27c} = Staff.create_feature(ft27, prefix)
    {:ok, ft28c} = Staff.create_feature(ft28, prefix)
    {:ok, ft29c} = Staff.create_feature(ft29, prefix)
    {:ok, ft30c} = Staff.create_feature(ft30, prefix)
    {:ok, ft31c} = Staff.create_feature(ft31, prefix)
    {:ok, ft32c} = Staff.create_feature(ft32, prefix)
    {:ok, ft33c} = Staff.create_feature(ft33, prefix)

    ft34 = %{"name" => "create Work order template", "code" => "CRWT", "module_id" => md3c.id}
    ft35 = %{"name" => "Edit work order template", "code" => "EDWT", "module_id" => md3c.id}
    ft36 = %{"name" => "Delete work order template", "code" => "DLWT", "module_id" => md3c.id}
    ft37 = %{"name" => "List view work order template", "code" => "LVWT", "module_id" => md3c.id}
    ft38 = %{"name" => "View work order template", "code" => "VIWT", "module_id" => md3c.id}
    ft39 = %{"name" => "Create WO Schedule", "code" => "CRWS", "module_id" => md3c.id}
    ft40 = %{"name" => "Edit WO Schedule", "code" => "EDWS", "module_id" => md3c.id}
    ft41 = %{"name" => "Delete WO Schedule", "code" => "DLWS", "module_id" => md3c.id}
    ft42 = %{"name" => "List view WO Schedule", "code" => "LVWS", "module_id" => md3c.id}
    ft43 = %{"name" => "View WO Schedule", "code" => "VIWS", "module_id" => md3c.id}
    ft44 = %{"name" => "Import WO Schedule", "code" => "IMWS", "module_id" => md3c.id}
    ft45 = %{"name" => "Create work order", "code" => "CRWO", "module_id" => md3c.id}
    ft46 = %{"name" => "Edit work order", "code" => "EDWO", "module_id" => md3c.id}
    ft47 = %{"name" => "Delete work order", "code" => "DLWO", "module_id" => md3c.id}
    ft48 = %{"name" => "List view work order", "code" => "LVWO", "module_id" => md3c.id}
    ft49 = %{"name" => "Execute work order", "code" => "EXWO", "module_id" => md3c.id}
    ft50 = %{"name" => "Reassign work order", "code" => "RAWO", "module_id" => md3c.id}
    ft51 = %{"name" => "Reschedule work order", "code" => "RSWO", "module_id" => md3c.id}
    ft52 = %{"name" => "View work order", "code" => "VIWO", "module_id" => md3c.id}
    ft53 = %{"name" => "Create Tasks list", "code" => "CRTL", "module_id" => md3c.id}
    ft54 = %{"name" => "Edit Tasks list", "code" => "EDTL", "module_id" => md3c.id}
    ft55 = %{"name" => "Delete Tasks list", "code" => "DLTL", "module_id" => md3c.id}
    ft56 = %{"name" => "List view tasks list", "code" => "LVTL", "module_id" => md3c.id}
    ft57 = %{"name" => "View Tasks list", "code" => "VITL", "module_id" => md3c.id}
    ft58 = %{"name" => "Import Task list", "code" => "IMTL", "module_id" => md3c.id}
    ft59 = %{"name" => "Create Check list", "code" => "CRCL", "module_id" => md3c.id}
    ft60 = %{"name" => "Edit Check list", "code" => "EDCL", "module_id" => md3c.id}
    ft61 = %{"name" => "Delete Check list", "code" => "DLCL", "module_id" => md3c.id}
    ft62 = %{"name" => "List view Check list", "code" => "LVCL", "module_id" => md3c.id}
    ft63 = %{"name" => "View Check list", "code" => "VICL", "module_id" => md3c.id}
    ft64 = %{"name" => "Import Check list", "code" => "IMCL", "module_id" => md3c.id}
    ft65 = %{"name" => "Create work permit", "code" => "CRWP", "module_id" => md3c.id}
    ft66 = %{"name" => "Edit work permit ", "code" => "EDWP", "module_id" => md3c.id}
    ft67 = %{"name" => "Delete work permit", "code" => "DLWP", "module_id" => md3c.id}
    ft68 = %{"name" => "List view work permit", "code" => "LVWP", "module_id" => md3c.id}
    ft69 = %{"name" => "View work permit", "code" => "VIWP", "module_id" => md3c.id}
    ft70 = %{"name" => "Import work permit", "code" => "IMWP", "module_id" => md3c.id}
    ft71 = %{"name" => "Create LOTO", "code" => "CRLT", "module_id" => md3c.id}
    ft72 = %{"name" => "Edit LOTO", "code" => "EDLT", "module_id" => md3c.id}
    ft73 = %{"name" => "Delete LOTO", "code" => "DLLT", "module_id" => md3c.id}
    ft74 = %{"name" => "List view LOTO", "code" => "LVLT", "module_id" => md3c.id}
    ft75 = %{"name" => "View LOTO", "code" => "VILT", "module_id" => md3c.id}
    ft76 = %{"name" => "Import LOTO", "code" => "IMLT", "module_id" => md3c.id}

    {:ok, ft34c} = Staff.create_feature(ft34, prefix)
    {:ok, ft35c} = Staff.create_feature(ft35, prefix)
    {:ok, ft36c} = Staff.create_feature(ft36, prefix)
    {:ok, ft37c} = Staff.create_feature(ft37, prefix)
    {:ok, ft38c} = Staff.create_feature(ft38, prefix)
    {:ok, ft39c} = Staff.create_feature(ft39, prefix)
    {:ok, ft40c} = Staff.create_feature(ft40, prefix)
    {:ok, ft41c} = Staff.create_feature(ft41, prefix)
    {:ok, ft42c} = Staff.create_feature(ft42, prefix)
    {:ok, ft43c} = Staff.create_feature(ft43, prefix)
    {:ok, ft44c} = Staff.create_feature(ft44, prefix)
    {:ok, ft45c} = Staff.create_feature(ft45, prefix)
    {:ok, ft46c} = Staff.create_feature(ft46, prefix)
    {:ok, ft47c} = Staff.create_feature(ft47, prefix)
    {:ok, ft48c} = Staff.create_feature(ft48, prefix)
    {:ok, ft49c} = Staff.create_feature(ft49, prefix)
    {:ok, ft50c} = Staff.create_feature(ft50, prefix)
    {:ok, ft51c} = Staff.create_feature(ft51, prefix)
    {:ok, ft52c} = Staff.create_feature(ft52, prefix)
    {:ok, ft53c} = Staff.create_feature(ft53, prefix)
    {:ok, ft54c} = Staff.create_feature(ft54, prefix)
    {:ok, ft55c} = Staff.create_feature(ft55, prefix)
    {:ok, ft56c} = Staff.create_feature(ft56, prefix)
    {:ok, ft57c} = Staff.create_feature(ft57, prefix)
    {:ok, ft58c} = Staff.create_feature(ft58, prefix)
    {:ok, ft59c} = Staff.create_feature(ft59, prefix)
    {:ok, ft60c} = Staff.create_feature(ft60, prefix)
    {:ok, ft61c} = Staff.create_feature(ft61, prefix)
    {:ok, ft62c} = Staff.create_feature(ft62, prefix)
    {:ok, ft63c} = Staff.create_feature(ft63, prefix)
    {:ok, ft64c} = Staff.create_feature(ft64, prefix)
    {:ok, ft65c} = Staff.create_feature(ft65, prefix)
    {:ok, ft66c} = Staff.create_feature(ft66, prefix)
    {:ok, ft67c} = Staff.create_feature(ft67, prefix)
    {:ok, ft68c} = Staff.create_feature(ft68, prefix)
    {:ok, ft69c} = Staff.create_feature(ft69, prefix)
    {:ok, ft70c} = Staff.create_feature(ft70, prefix)
    {:ok, ft71c} = Staff.create_feature(ft71, prefix)
    {:ok, ft72c} = Staff.create_feature(ft72, prefix)
    {:ok, ft73c} = Staff.create_feature(ft73, prefix)
    {:ok, ft74c} = Staff.create_feature(ft74, prefix)
    {:ok, ft75c} = Staff.create_feature(ft75, prefix)
    {:ok, ft76c} = Staff.create_feature(ft76, prefix)

    ft77 = %{"name" => "Create Users", "code" => "CRUS", "module_id" => md4c.id}
    ft78 = %{"name" => "Edit Users", "code" => "EDUS", "module_id" => md4c.id}
    ft79 = %{"name" => "Delete Users", "code" => "DLUS", "module_id" => md4c.id}
    ft80 = %{"name" => "List View Users", "code" => "LVUS", "module_id" => md4c.id}
    ft81 = %{"name" => "View Users", "code" => "VIUS", "module_id" => md4c.id}
    ft82 = %{"name" => "Create Users profile", "code" => "CRUP", "module_id" => md4c.id}
    ft83 = %{"name" => "Edit Users profile", "code" => "EDUP", "module_id" => md4c.id}
    ft84 = %{"name" => "Delete Users profile", "code" => "DLUP", "module_id" => md4c.id}
    ft85 = %{"name" => "List View Users profile", "code" => "LVUP", "module_id" => md4c.id}
    ft86 = %{"name" => "View Users profile", "code" => "VIUP", "module_id" => md4c.id}
    ft87 = %{"name" => "Create Users roster", "code" => "CRUR", "module_id" => md4c.id}
    ft88 = %{"name" => "Edit Users roster", "code" => "EDUR", "module_id" => md4c.id}
    ft89 = %{"name" => "Delete Users roster", "code" => "DLUR", "module_id" => md4c.id}
    ft90 = %{"name" => "List View Users roster", "code" => "LVUR", "module_id" => md4c.id}
    ft91 = %{"name" => "View Users roster", "code" => "VIUR", "module_id" => md4c.id}
    ft92 = %{"name" => "Create User group", "code" => "CRUG", "module_id" => md4c.id}
    ft93 = %{"name" => "Edit User group", "code" => "EDUG", "module_id" => md4c.id}
    ft94 = %{"name" => "Delete User group", "code" => "DLUG", "module_id" => md4c.id}
    ft95 = %{"name" => "List View User group", "code" => "LVUG", "module_id" => md4c.id}
    ft96 = %{"name" => "View User group", "code" => "VIUG", "module_id" => md4c.id}

    {:ok, ft77c} = Staff.create_feature(ft77, prefix)
    {:ok, ft78c} = Staff.create_feature(ft78, prefix)
    {:ok, ft79c} = Staff.create_feature(ft79, prefix)
    {:ok, ft80c} = Staff.create_feature(ft80, prefix)
    {:ok, ft81c} = Staff.create_feature(ft81, prefix)
    {:ok, ft82c} = Staff.create_feature(ft82, prefix)
    {:ok, ft83c} = Staff.create_feature(ft83, prefix)
    {:ok, ft84c} = Staff.create_feature(ft84, prefix)
    {:ok, ft85c} = Staff.create_feature(ft85, prefix)
    {:ok, ft86c} = Staff.create_feature(ft86, prefix)
    {:ok, ft87c} = Staff.create_feature(ft87, prefix)
    {:ok, ft88c} = Staff.create_feature(ft88, prefix)
    {:ok, ft89c} = Staff.create_feature(ft89, prefix)
    {:ok, ft90c} = Staff.create_feature(ft90, prefix)
    {:ok, ft91c} = Staff.create_feature(ft91, prefix)
    {:ok, ft92c} = Staff.create_feature(ft92, prefix)
    {:ok, ft93c} = Staff.create_feature(ft93, prefix)
    {:ok, ft94c} = Staff.create_feature(ft94, prefix)
    {:ok, ft95c} = Staff.create_feature(ft95, prefix)
    {:ok, ft96c} = Staff.create_feature(ft96, prefix)

    ft97 = %{"name" => "Create part", "code" => "CRPA", "module_id" => md5c.id}
    ft98 = %{"name" => "Edit part", "code" => "EDPA", "module_id" => md5c.id}
    ft99 = %{"name" => "Delete part", "code" => "DLPA", "module_id" => md5c.id}
    ft100 = %{"name" => "View part", "code" => "VIPA", "module_id" => md5c.id}
    ft101 = %{"name" => "import part", "code" => "IMPA", "module_id" => md5c.id}
    ft102 = %{"name" => "Create part details", "code" => "CRPD", "module_id" => md5c.id}
    ft103 = %{"name" => "Edit part details", "code" => "EDPD", "module_id" => md5c.id}
    ft104 = %{"name" => "Delete part details", "code" => "DLPD", "module_id" => md5c.id}
    ft105 = %{"name" => "View part details", "code" => "VIPD", "module_id" => md5c.id}
    ft106 = %{"name" => "import part details", "code" => "IMPD", "module_id" => md5c.id}

    {:ok, ft97c} = Staff.create_feature(ft97, prefix)
    {:ok, ft98c} = Staff.create_feature(ft98, prefix)
    {:ok, ft99c} = Staff.create_feature(ft99, prefix)
    {:ok, ft100c} = Staff.create_feature(ft100, prefix)
    {:ok, ft101c} = Staff.create_feature(ft101, prefix)
    {:ok, ft102c} = Staff.create_feature(ft102, prefix)
    {:ok, ft103c} = Staff.create_feature(ft103, prefix)
    {:ok, ft104c} = Staff.create_feature(ft104, prefix)
    {:ok, ft105c} = Staff.create_feature(ft105, prefix)
    {:ok, ft106c} = Staff.create_feature(ft106, prefix)

    ft107 = %{"name" => "Create tickets", "code" => "CRTI", "module_id" => md6c.id}
    ft108 = %{"name" => "Edit tickets", "code" => "EDTI", "module_id" => md6c.id}
    ft109 = %{"name" => "Delete tickets", "code" => "DLTI", "module_id" => md6c.id}
    ft110 = %{"name" => "Assign tickets", "code" => "ASTI", "module_id" => md6c.id}
    ft111 = %{"name" => "Reassign tickets", "code" => "RATI", "module_id" => md6c.id}
    ft112 = %{"name" => "Close tickets", "code" => "CLTI", "module_id" => md6c.id}
    ft113 = %{"name" => "Put tickets on Hold", "code" => "PTOH", "module_id" => md6c.id}
    ft114 = %{"name" => "Edit ticket status", "code" => "EDTS", "module_id" => md6c.id}
    ft115 = %{"name" => "Reopen ticket", "code" => "ROTI", "module_id" => md6c.id}

    {:ok, ft107c} = Staff.create_feature(ft107, prefix)
    {:ok, ft108c} = Staff.create_feature(ft108, prefix)
    {:ok, ft109c} = Staff.create_feature(ft109, prefix)
    {:ok, ft110c} = Staff.create_feature(ft110, prefix)
    {:ok, ft111c} = Staff.create_feature(ft111, prefix)
    {:ok, ft112c} = Staff.create_feature(ft112, prefix)
    {:ok, ft113c} = Staff.create_feature(ft113, prefix)
    {:ok, ft114c} = Staff.create_feature(ft114, prefix)
    {:ok, ft115c} = Staff.create_feature(ft115, prefix)

    ft116 = %{"name" => "Create alerts", "code" => "CRAL", "module_id" => md7c.id}
    ft117 = %{"name" => "Edit alerts", "code" => "EDAL", "module_id" => md7c.id}
    ft118 = %{"name" => "Delete alerts", "code" => "DLAL", "module_id" => md7c.id}
    ft119 = %{"name" => "Acknowledge alerts", "code" => "AKAL", "module_id" => md7c.id}
    ft120 = %{"name" => "Disable alerts", "code" => "DIAL", "module_id" => md7c.id}
    ft121 = %{"name" => "import alerts", "code" => "IMAL", "module_id" => md7c.id}
    ft122 = %{"name" => "View alerts", "code" => "VIAL", "module_id" => md7c.id}
    ft123 = %{"name" => "Create notifications", "code" => "CRNT", "module_id" => md7c.id}
    ft124 = %{"name" => "Edit notofications", "code" => "EDNT", "module_id" => md7c.id}
    ft125 = %{"name" => "Delete notifications", "code" => "DLNT", "module_id" => md7c.id}
    ft126 = %{"name" => "Disable notifications", "code" => "DINT", "module_id" => md7c.id}
    ft127 = %{"name" => "import notifications", "code" => "IMNT", "module_id" => md7c.id}
    ft128 = %{"name" => "Acknowledge notifications", "code" => "AKNT", "module_id" => md7c.id}
    ft129 = %{"name" => "View notifications", "code" => "VINT", "module_id" => md7c.id}

    {:ok, ft116c} = Staff.create_feature(ft116, prefix)
    {:ok, ft117c} = Staff.create_feature(ft117, prefix)
    {:ok, ft118c} = Staff.create_feature(ft118, prefix)
    {:ok, ft119c} = Staff.create_feature(ft119, prefix)
    {:ok, ft120c} = Staff.create_feature(ft120, prefix)
    {:ok, ft121c} = Staff.create_feature(ft121, prefix)
    {:ok, ft122c} = Staff.create_feature(ft122, prefix)
    {:ok, ft123c} = Staff.create_feature(ft123, prefix)
    {:ok, ft124c} = Staff.create_feature(ft124, prefix)
    {:ok, ft125c} = Staff.create_feature(ft125, prefix)
    {:ok, ft126c} = Staff.create_feature(ft126, prefix)
    {:ok, ft127c} = Staff.create_feature(ft127, prefix)
    {:ok, ft128c} = Staff.create_feature(ft128, prefix)
    {:ok, ft129c} = Staff.create_feature(ft129, prefix)

    ft130 = %{"name" => "Reports - Data download", "code" => "REDD", "module_id" => md8c.id}
    ft131 = %{"name" => "Reports - Print", "code" => "REPR", "module_id" => md8c.id}
    ft132 = %{"name" => "Dashboard & Reports - create", "code" => "DRCR", "module_id" => md8c.id}
    ft133 = %{"name" => "Dashboard & Reports - edit", "code" => "DRED", "module_id" => md8c.id}
    ft134 = %{"name" => "Dashboard & Reports - View", "code" => "DRVI", "module_id" => md8c.id}

    {:ok, ft130c} = Staff.create_feature(ft130, prefix)
    {:ok, ft131c} = Staff.create_feature(ft131, prefix)
    {:ok, ft132c} = Staff.create_feature(ft132, prefix)
    {:ok, ft133c} = Staff.create_feature(ft133, prefix)
    {:ok, ft134c} = Staff.create_feature(ft134, prefix)

    # role_prof1 = %{"name" => "Super Admin", "code" => "SPAD",
    #                 "permissions" => [
    #                   %{"module_code" => md1c.code,
    #                    "module_name" => md1c.name,
    #                    "features" => [
    #                          %{"feature_code" => ft1c.code, "feature_name" => ft1c.name, "access" => true},
    #                          %{"feature_code" => ft2c.code, "feature_name" => ft2c.name, "access" => true},
    #                          %{"feature_code" => ft3c.code, "feature_name" => ft3c.name, "access" => true},
    #                          %{"feature_code" => ft4c.code, "feature_name" => ft4c.name, "access" => true},
    #                          %{"feature_code" => ft5c.code, "feature_name" => ft5c.name, "access" => true},
    #                          %{"feature_code" => ft6c.code, "feature_name" => ft6c.name, "access" => true},
    #                          %{"feature_code" => ft7c.code, "feature_name" => ft7c.name, "access" => true},
    #                          %{"feature_code" => ft8c.code, "feature_name" => ft8c.name, "access" => true},
    #                          %{"feature_code" => ft9c.code, "feature_name" => ft9c.name, "access" => true},
    #                          %{"feature_code" => ft10c.code, "feature_name" => ft10c.name, "access" => true},
    #                          %{"feature_code" => ft11c.code, "feature_name" => ft11c.name, "access" => true},
    #                          %{"feature_code" => ft12c.code, "feature_name" => ft12c.name, "access" => true},
    #                          %{"feature_code" => ft13c.code, "feature_name" => ft13c.name, "access" => true},
    #                          %{"feature_code" => ft14c.code, "feature_name" => ft14c.name, "access" => true},
    #                          %{"feature_code" => ft15c.code, "feature_name" => ft15c.name, "access" => true},
    #                          %{"feature_code" => ft16c.code, "feature_name" => ft16c.name, "access" => true}
    #                        ]
    #                    },

    #                    %{"module_code" => md2c.code,
    #                     "module_name" => md2c.name,
    #                     "features" => [
    #                           %{"feature_code" => ft17c.code, "feature_name" => ft17c.name, "access" => true},
    #                           %{"feature_code" => ft18c.code, "feature_name" => ft18c.name, "access" => true},
    #                           %{"feature_code" => ft19c.code, "feature_name" => ft19c.name, "access" => true},
    #                           %{"feature_code" => ft20c.code, "feature_name" => ft20c.name, "access" => true},
    #                           %{"feature_code" => ft21c.code, "feature_name" => ft21c.name, "access" => true},
    #                           %{"feature_code" => ft22c.code, "feature_name" => ft22c.name, "access" => true},
    #                           %{"feature_code" => ft23c.code, "feature_name" => ft23c.name, "access" => true},
    #                           %{"feature_code" => ft24c.code, "feature_name" => ft24c.name, "access" => true},
    #                           %{"feature_code" => ft25c.code, "feature_name" => ft25c.name, "access" => true},
    #                           %{"feature_code" => ft26c.code, "feature_name" => ft26c.name, "access" => true},
    #                           %{"feature_code" => ft27c.code, "feature_name" => ft27c.name, "access" => true},
    #                           %{"feature_code" => ft28c.code, "feature_name" => ft28c.name, "access" => true},
    #                           %{"feature_code" => ft29c.code, "feature_name" => ft29c.name, "access" => true},
    #                           %{"feature_code" => ft30c.code, "feature_name" => ft30c.name, "access" => true},
    #                           %{"feature_code" => ft31c.code, "feature_name" => ft31c.name, "access" => true},
    #                           %{"feature_code" => ft32c.code, "feature_name" => ft32c.name, "access" => true},
    #                           %{"feature_code" => ft33c.code, "feature_name" => ft33c.name, "access" => true}
    #                         ]
    #                     },

    #                     %{"module_code" => md3c.code,
    #                      "module_name" => md3c.name,
    #                      "features" => [
    #                               %{"feature_code" => ft34c.code, "feature_name" => ft34c.name, "access" => true},
    #                               %{"feature_code" => ft35c.code, "feature_name" => ft35c.name, "access" => true},
    #                               %{"feature_code" => ft36c.code, "feature_name" => ft36c.name, "access" => true},
    #                               %{"feature_code" => ft37c.code, "feature_name" => ft37c.name, "access" => true},
    #                               %{"feature_code" => ft38c.code, "feature_name" => ft38c.name, "access" => true},
    #                               %{"feature_code" => ft39c.code, "feature_name" => ft39c.name, "access" => true},
    #                               %{"feature_code" => ft40c.code, "feature_name" => ft40c.name, "access" => true},
    #                               %{"feature_code" => ft41c.code, "feature_name" => ft41c.name, "access" => true},
    #                               %{"feature_code" => ft42c.code, "feature_name" => ft42c.name, "access" => true},
    #                               %{"feature_code" => ft43c.code, "feature_name" => ft43c.name, "access" => true},
    #                               %{"feature_code" => ft44c.code, "feature_name" => ft44c.name, "access" => true},
    #                               %{"feature_code" => ft45c.code, "feature_name" => ft45c.name, "access" => true},
    #                               %{"feature_code" => ft46c.code, "feature_name" => ft46c.name, "access" => true},
    #                               %{"feature_code" => ft47c.code, "feature_name" => ft47c.name, "access" => true},
    #                               %{"feature_code" => ft48c.code, "feature_name" => ft48c.name, "access" => true},
    #                               %{"feature_code" => ft49c.code, "feature_name" => ft49c.name, "access" => true},
    #                               %{"feature_code" => ft50c.code, "feature_name" => ft50c.name, "access" => true},
    #                               %{"feature_code" => ft51c.code, "feature_name" => ft51c.name, "access" => true},
    #                               %{"feature_code" => ft52c.code, "feature_name" => ft52c.name, "access" => true},
    #                               %{"feature_code" => ft53c.code, "feature_name" => ft53c.name, "access" => true},
    #                               %{"feature_code" => ft54c.code, "feature_name" => ft54c.name, "access" => true},
    #                               %{"feature_code" => ft55c.code, "feature_name" => ft55c.name, "access" => true},
    #                               %{"feature_code" => ft56c.code, "feature_name" => ft56c.name, "access" => true},
    #                               %{"feature_code" => ft57c.code, "feature_name" => ft57c.name, "access" => true},
    #                               %{"feature_code" => ft58c.code, "feature_name" => ft58c.name, "access" => true},
    #                               %{"feature_code" => ft59c.code, "feature_name" => ft59c.name, "access" => true},
    #                               %{"feature_code" => ft60c.code, "feature_name" => ft60c.name, "access" => true},
    #                               %{"feature_code" => ft61c.code, "feature_name" => ft61c.name, "access" => true},
    #                               %{"feature_code" => ft62c.code, "feature_name" => ft62c.name, "access" => true},
    #                               %{"feature_code" => ft63c.code, "feature_name" => ft63c.name, "access" => true},
    #                               %{"feature_code" => ft64c.code, "feature_name" => ft64c.name, "access" => true},
    #                               %{"feature_code" => ft65c.code, "feature_name" => ft65c.name, "access" => true},
    #                               %{"feature_code" => ft66c.code, "feature_name" => ft66c.name, "access" => true},
    #                               %{"feature_code" => ft67c.code, "feature_name" => ft67c.name, "access" => true},
    #                               %{"feature_code" => ft68c.code, "feature_name" => ft68c.name, "access" => true},
    #                               %{"feature_code" => ft69c.code, "feature_name" => ft69c.name, "access" => true},
    #                               %{"feature_code" => ft70c.code, "feature_name" => ft70c.name, "access" => true},
    #                               %{"feature_code" => ft71c.code, "feature_name" => ft71c.name, "access" => true},
    #                               %{"feature_code" => ft72c.code, "feature_name" => ft72c.name, "access" => true},
    #                               %{"feature_code" => ft73c.code, "feature_name" => ft73c.name, "access" => true},
    #                               %{"feature_code" => ft74c.code, "feature_name" => ft74c.name, "access" => true},
    #                               %{"feature_code" => ft75c.code, "feature_name" => ft75c.name, "access" => true},
    #                               %{"feature_code" => ft76c.code, "feature_name" => ft76c.name, "access" => true}
    #                          ]
    #                      },

    #                      %{"module_code" => md4c.code,
    #                       "module_name" => md4c.name,
    #                       "features" => [
    #                             %{"feature_code" => ft77c.code, "feature_name" => ft77c.name, "access" => true},
    #                             %{"feature_code" => ft78c.code, "feature_name" => ft78c.name, "access" => true},
    #                             %{"feature_code" => ft79c.code, "feature_name" => ft79c.name, "access" => true},
    #                             %{"feature_code" => ft80c.code, "feature_name" => ft80c.name, "access" => true},
    #                             %{"feature_code" => ft81c.code, "feature_name" => ft81c.name, "access" => true},
    #                             %{"feature_code" => ft82c.code, "feature_name" => ft82c.name, "access" => true},
    #                             %{"feature_code" => ft83c.code, "feature_name" => ft83c.name, "access" => true},
    #                             %{"feature_code" => ft84c.code, "feature_name" => ft84c.name, "access" => true},
    #                             %{"feature_code" => ft85c.code, "feature_name" => ft85c.name, "access" => true},
    #                             %{"feature_code" => ft86c.code, "feature_name" => ft86c.name, "access" => true},
    #                             %{"feature_code" => ft87c.code, "feature_name" => ft87c.name, "access" => true},
    #                             %{"feature_code" => ft88c.code, "feature_name" => ft88c.name, "access" => true},
    #                             %{"feature_code" => ft89c.code, "feature_name" => ft89c.name, "access" => true},
    #                             %{"feature_code" => ft90c.code, "feature_name" => ft90c.name, "access" => true},
    #                             %{"feature_code" => ft91c.code, "feature_name" => ft91c.name, "access" => true},
    #                             %{"feature_code" => ft92c.code, "feature_name" => ft92c.name, "access" => true},
    #                             %{"feature_code" => ft93c.code, "feature_name" => ft93c.name, "access" => true},
    #                             %{"feature_code" => ft94c.code, "feature_name" => ft94c.name, "access" => true},
    #                             %{"feature_code" => ft95c.code, "feature_name" => ft95c.name, "access" => true},
    #                             %{"feature_code" => ft96c.code, "feature_name" => ft96c.name, "access" => true}
    #                           ]
    #                       },

    #                       %{"module_code" => md5c.code,
    #                        "module_name" => md5c.name,
    #                        "features" => [
    #                             %{"feature_code" => ft97c.code, "feature_name" => ft97c.name, "access" => true},
    #                             %{"feature_code" => ft98c.code, "feature_name" => ft98c.name, "access" => true},
    #                             %{"feature_code" => ft99c.code, "feature_name" => ft99c.name, "access" => true},
    #                             %{"feature_code" => ft100c.code, "feature_name" => ft100c.name, "access" => true},
    #                             %{"feature_code" => ft101c.code, "feature_name" => ft101c.name, "access" => true},
    #                             %{"feature_code" => ft102c.code, "feature_name" => ft102c.name, "access" => true},
    #                             %{"feature_code" => ft103c.code, "feature_name" => ft103c.name, "access" => true},
    #                             %{"feature_code" => ft104c.code, "feature_name" => ft104c.name, "access" => true},
    #                             %{"feature_code" => ft105c.code, "feature_name" => ft105c.name, "access" => true},
    #                             %{"feature_code" => ft106c.code, "feature_name" => ft106c.name, "access" => true}
    #                            ]
    #                        },

    #                        %{"module_code" => md6c.code,
    #                         "module_name" => md6c.name,
    #                         "features" => [
    #                             %{"feature_code" => ft107c.code, "feature_name" => ft107c.name, "access" => true},
    #                             %{"feature_code" => ft108c.code, "feature_name" => ft108c.name, "access" => true},
    #                             %{"feature_code" => ft109c.code, "feature_name" => ft109c.name, "access" => true},
    #                             %{"feature_code" => ft110c.code, "feature_name" => ft110c.name, "access" => true},
    #                             %{"feature_code" => ft111c.code, "feature_name" => ft111c.name, "access" => true},
    #                             %{"feature_code" => ft112c.code, "feature_name" => ft112c.name, "access" => true},
    #                             %{"feature_code" => ft113c.code, "feature_name" => ft113c.name, "access" => true},
    #                             %{"feature_code" => ft114c.code, "feature_name" => ft114c.name, "access" => true},
    #                             %{"feature_code" => ft115c.code, "feature_name" => ft115c.name, "access" => true}
    #                             ]
    #                         },

    #                         %{"module_code" => md7c.code,
    #                          "module_name" => md7c.name,
    #                          "features" => [
    #                              %{"feature_code" => ft116c.code, "feature_name" => ft116c.name, "access" => true},
    #                              %{"feature_code" => ft117c.code, "feature_name" => ft117c.name, "access" => true},
    #                              %{"feature_code" => ft118c.code, "feature_name" => ft118c.name, "access" => true},
    #                              %{"feature_code" => ft119c.code, "feature_name" => ft119c.name, "access" => true},
    #                              %{"feature_code" => ft120c.code, "feature_name" => ft120c.name, "access" => true},
    #                              %{"feature_code" => ft121c.code, "feature_name" => ft121c.name, "access" => true},
    #                              %{"feature_code" => ft122c.code, "feature_name" => ft122c.name, "access" => true},
    #                              %{"feature_code" => ft123c.code, "feature_name" => ft123c.name, "access" => true},
    #                              %{"feature_code" => ft124c.code, "feature_name" => ft124c.name, "access" => true},
    #                              %{"feature_code" => ft125c.code, "feature_name" => ft125c.name, "access" => true},
    #                              %{"feature_code" => ft126c.code, "feature_name" => ft126c.name, "access" => true},
    #                              %{"feature_code" => ft127c.code, "feature_name" => ft127c.name, "access" => true},
    #                              %{"feature_code" => ft128c.code, "feature_name" => ft128c.name, "access" => true},
    #                              %{"feature_code" => ft129c.code, "feature_name" => ft129c.name, "access" => true}
    #                              ]
    #                          },

    #                          %{"module_code" => md8c.code,
    #                           "module_name" => md8c.name,
    #                           "features" => [
    #                               %{"feature_code" => ft130c.code, "feature_name" => ft130c.name, "access" => true},
    #                               %{"feature_code" => ft131c.code, "feature_name" => ft131c.name, "access" => true},
    #                               %{"feature_code" => ft132c.code, "feature_name" => ft132c.name, "access" => true},
    #                               %{"feature_code" => ft133c.code, "feature_name" => ft133c.name, "access" => true},
    #                               %{"feature_code" => ft134c.code, "feature_name" => ft134c.name, "access" => true},
    #                               ]
    #                             }
    #                  ]
    #               }



    role_prof2 = %{"name" => "Admin", "code" => "ADMN",
                    "permissions" => [
                      %{"module_code" => md1c.code,
                       "module_name" => md1c.name,
                       "features" => [
                             %{"feature_code" => ft1c.code, "feature_name" => ft1c.name, "access" => false},
                             %{"feature_code" => ft2c.code, "feature_name" => ft2c.name, "access" => false},
                             %{"feature_code" => ft3c.code, "feature_name" => ft3c.name, "access" => false},
                             %{"feature_code" => ft4c.code, "feature_name" => ft4c.name, "access" => true},
                             %{"feature_code" => ft5c.code, "feature_name" => ft5c.name, "access" => true},
                             %{"feature_code" => ft6c.code, "feature_name" => ft6c.name, "access" => false},
                             %{"feature_code" => ft7c.code, "feature_name" => ft7c.name, "access" => true},
                             %{"feature_code" => ft8c.code, "feature_name" => ft8c.name, "access" => true},
                             %{"feature_code" => ft9c.code, "feature_name" => ft9c.name, "access" => true},
                             %{"feature_code" => ft10c.code, "feature_name" => ft10c.name, "access" => true},
                             %{"feature_code" => ft11c.code, "feature_name" => ft11c.name, "access" => true},
                             %{"feature_code" => ft12c.code, "feature_name" => ft12c.name, "access" => true},
                             %{"feature_code" => ft13c.code, "feature_name" => ft13c.name, "access" => true},
                             %{"feature_code" => ft14c.code, "feature_name" => ft14c.name, "access" => true},
                             %{"feature_code" => ft15c.code, "feature_name" => ft15c.name, "access" => true},
                             %{"feature_code" => ft16c.code, "feature_name" => ft16c.name, "access" => true}
                           ]
                       },

                       %{"module_code" => md2c.code,
                        "module_name" => md2c.name,
                        "features" => [
                              %{"feature_code" => ft17c.code, "feature_name" => ft17c.name, "access" => true},
                              %{"feature_code" => ft18c.code, "feature_name" => ft18c.name, "access" => true},
                              %{"feature_code" => ft19c.code, "feature_name" => ft19c.name, "access" => true},
                              %{"feature_code" => ft20c.code, "feature_name" => ft20c.name, "access" => true},
                              %{"feature_code" => ft21c.code, "feature_name" => ft21c.name, "access" => true},
                              %{"feature_code" => ft22c.code, "feature_name" => ft22c.name, "access" => true},
                              %{"feature_code" => ft23c.code, "feature_name" => ft23c.name, "access" => true},
                              %{"feature_code" => ft24c.code, "feature_name" => ft24c.name, "access" => true},
                              %{"feature_code" => ft25c.code, "feature_name" => ft25c.name, "access" => true},
                              %{"feature_code" => ft26c.code, "feature_name" => ft26c.name, "access" => true},
                              %{"feature_code" => ft27c.code, "feature_name" => ft27c.name, "access" => true},
                              %{"feature_code" => ft28c.code, "feature_name" => ft28c.name, "access" => true},
                              %{"feature_code" => ft29c.code, "feature_name" => ft29c.name, "access" => true},
                              %{"feature_code" => ft30c.code, "feature_name" => ft30c.name, "access" => true},
                              %{"feature_code" => ft31c.code, "feature_name" => ft31c.name, "access" => true},
                              %{"feature_code" => ft32c.code, "feature_name" => ft32c.name, "access" => true},
                              %{"feature_code" => ft33c.code, "feature_name" => ft33c.name, "access" => true}
                            ]
                        },

                        %{"module_code" => md3c.code,
                         "module_name" => md3c.name,
                         "features" => [
                                  %{"feature_code" => ft34c.code, "feature_name" => ft34c.name, "access" => true},
                                  %{"feature_code" => ft35c.code, "feature_name" => ft35c.name, "access" => true},
                                  %{"feature_code" => ft36c.code, "feature_name" => ft36c.name, "access" => true},
                                  %{"feature_code" => ft37c.code, "feature_name" => ft37c.name, "access" => true},
                                  %{"feature_code" => ft38c.code, "feature_name" => ft38c.name, "access" => true},
                                  %{"feature_code" => ft39c.code, "feature_name" => ft39c.name, "access" => true},
                                  %{"feature_code" => ft40c.code, "feature_name" => ft40c.name, "access" => true},
                                  %{"feature_code" => ft41c.code, "feature_name" => ft41c.name, "access" => true},
                                  %{"feature_code" => ft42c.code, "feature_name" => ft42c.name, "access" => true},
                                  %{"feature_code" => ft43c.code, "feature_name" => ft43c.name, "access" => true},
                                  %{"feature_code" => ft44c.code, "feature_name" => ft44c.name, "access" => true},
                                  %{"feature_code" => ft45c.code, "feature_name" => ft45c.name, "access" => true},
                                  %{"feature_code" => ft46c.code, "feature_name" => ft46c.name, "access" => true},
                                  %{"feature_code" => ft47c.code, "feature_name" => ft47c.name, "access" => true},
                                  %{"feature_code" => ft48c.code, "feature_name" => ft48c.name, "access" => true},
                                  %{"feature_code" => ft49c.code, "feature_name" => ft49c.name, "access" => true},
                                  %{"feature_code" => ft50c.code, "feature_name" => ft50c.name, "access" => true},
                                  %{"feature_code" => ft51c.code, "feature_name" => ft51c.name, "access" => true},
                                  %{"feature_code" => ft52c.code, "feature_name" => ft52c.name, "access" => true},
                                  %{"feature_code" => ft53c.code, "feature_name" => ft53c.name, "access" => true},
                                  %{"feature_code" => ft54c.code, "feature_name" => ft54c.name, "access" => true},
                                  %{"feature_code" => ft55c.code, "feature_name" => ft55c.name, "access" => true},
                                  %{"feature_code" => ft56c.code, "feature_name" => ft56c.name, "access" => true},
                                  %{"feature_code" => ft57c.code, "feature_name" => ft57c.name, "access" => true},
                                  %{"feature_code" => ft58c.code, "feature_name" => ft58c.name, "access" => true},
                                  %{"feature_code" => ft59c.code, "feature_name" => ft59c.name, "access" => true},
                                  %{"feature_code" => ft60c.code, "feature_name" => ft60c.name, "access" => true},
                                  %{"feature_code" => ft61c.code, "feature_name" => ft61c.name, "access" => true},
                                  %{"feature_code" => ft62c.code, "feature_name" => ft62c.name, "access" => true},
                                  %{"feature_code" => ft63c.code, "feature_name" => ft63c.name, "access" => true},
                                  %{"feature_code" => ft64c.code, "feature_name" => ft64c.name, "access" => true},
                                  %{"feature_code" => ft65c.code, "feature_name" => ft65c.name, "access" => true},
                                  %{"feature_code" => ft66c.code, "feature_name" => ft66c.name, "access" => true},
                                  %{"feature_code" => ft67c.code, "feature_name" => ft67c.name, "access" => true},
                                  %{"feature_code" => ft68c.code, "feature_name" => ft68c.name, "access" => true},
                                  %{"feature_code" => ft69c.code, "feature_name" => ft69c.name, "access" => true},
                                  %{"feature_code" => ft70c.code, "feature_name" => ft70c.name, "access" => true},
                                  %{"feature_code" => ft71c.code, "feature_name" => ft71c.name, "access" => true},
                                  %{"feature_code" => ft72c.code, "feature_name" => ft72c.name, "access" => true},
                                  %{"feature_code" => ft73c.code, "feature_name" => ft73c.name, "access" => true},
                                  %{"feature_code" => ft74c.code, "feature_name" => ft74c.name, "access" => true},
                                  %{"feature_code" => ft75c.code, "feature_name" => ft75c.name, "access" => true},
                                  %{"feature_code" => ft76c.code, "feature_name" => ft76c.name, "access" => true}
                             ]
                         },

                         %{"module_code" => md4c.code,
                          "module_name" => md4c.name,
                          "features" => [
                                %{"feature_code" => ft77c.code, "feature_name" => ft77c.name, "access" => true},
                                %{"feature_code" => ft78c.code, "feature_name" => ft78c.name, "access" => true},
                                %{"feature_code" => ft79c.code, "feature_name" => ft79c.name, "access" => true},
                                %{"feature_code" => ft80c.code, "feature_name" => ft80c.name, "access" => true},
                                %{"feature_code" => ft81c.code, "feature_name" => ft81c.name, "access" => true},
                                %{"feature_code" => ft82c.code, "feature_name" => ft82c.name, "access" => true},
                                %{"feature_code" => ft83c.code, "feature_name" => ft83c.name, "access" => true},
                                %{"feature_code" => ft84c.code, "feature_name" => ft84c.name, "access" => true},
                                %{"feature_code" => ft85c.code, "feature_name" => ft85c.name, "access" => true},
                                %{"feature_code" => ft86c.code, "feature_name" => ft86c.name, "access" => true},
                                %{"feature_code" => ft87c.code, "feature_name" => ft87c.name, "access" => true},
                                %{"feature_code" => ft88c.code, "feature_name" => ft88c.name, "access" => true},
                                %{"feature_code" => ft89c.code, "feature_name" => ft89c.name, "access" => true},
                                %{"feature_code" => ft90c.code, "feature_name" => ft90c.name, "access" => true},
                                %{"feature_code" => ft91c.code, "feature_name" => ft91c.name, "access" => true},
                                %{"feature_code" => ft92c.code, "feature_name" => ft92c.name, "access" => true},
                                %{"feature_code" => ft93c.code, "feature_name" => ft93c.name, "access" => true},
                                %{"feature_code" => ft94c.code, "feature_name" => ft94c.name, "access" => true},
                                %{"feature_code" => ft95c.code, "feature_name" => ft95c.name, "access" => true},
                                %{"feature_code" => ft96c.code, "feature_name" => ft96c.name, "access" => true}
                              ]
                          },

                          %{"module_code" => md5c.code,
                           "module_name" => md5c.name,
                           "features" => [
                                %{"feature_code" => ft97c.code, "feature_name" => ft97c.name, "access" => true},
                                %{"feature_code" => ft98c.code, "feature_name" => ft98c.name, "access" => true},
                                %{"feature_code" => ft99c.code, "feature_name" => ft99c.name, "access" => true},
                                %{"feature_code" => ft100c.code, "feature_name" => ft100c.name, "access" => true},
                                %{"feature_code" => ft101c.code, "feature_name" => ft101c.name, "access" => true},
                                %{"feature_code" => ft102c.code, "feature_name" => ft102c.name, "access" => true},
                                %{"feature_code" => ft103c.code, "feature_name" => ft103c.name, "access" => true},
                                %{"feature_code" => ft104c.code, "feature_name" => ft104c.name, "access" => true},
                                %{"feature_code" => ft105c.code, "feature_name" => ft105c.name, "access" => true},
                                %{"feature_code" => ft106c.code, "feature_name" => ft106c.name, "access" => true}
                               ]
                           },

                           %{"module_code" => md6c.code,
                            "module_name" => md6c.name,
                            "features" => [
                                %{"feature_code" => ft107c.code, "feature_name" => ft107c.name, "access" => true},
                                %{"feature_code" => ft108c.code, "feature_name" => ft108c.name, "access" => true},
                                %{"feature_code" => ft109c.code, "feature_name" => ft109c.name, "access" => true},
                                %{"feature_code" => ft110c.code, "feature_name" => ft110c.name, "access" => true},
                                %{"feature_code" => ft111c.code, "feature_name" => ft111c.name, "access" => true},
                                %{"feature_code" => ft112c.code, "feature_name" => ft112c.name, "access" => true},
                                %{"feature_code" => ft113c.code, "feature_name" => ft113c.name, "access" => true},
                                %{"feature_code" => ft114c.code, "feature_name" => ft114c.name, "access" => true},
                                %{"feature_code" => ft115c.code, "feature_name" => ft115c.name, "access" => true}
                                ]
                            },

                            %{"module_code" => md7c.code,
                             "module_name" => md7c.name,
                             "features" => [
                                 %{"feature_code" => ft116c.code, "feature_name" => ft116c.name, "access" => true},
                                 %{"feature_code" => ft117c.code, "feature_name" => ft117c.name, "access" => true},
                                 %{"feature_code" => ft118c.code, "feature_name" => ft118c.name, "access" => true},
                                 %{"feature_code" => ft119c.code, "feature_name" => ft119c.name, "access" => true},
                                 %{"feature_code" => ft120c.code, "feature_name" => ft120c.name, "access" => true},
                                 %{"feature_code" => ft121c.code, "feature_name" => ft121c.name, "access" => true},
                                 %{"feature_code" => ft122c.code, "feature_name" => ft122c.name, "access" => true},
                                 %{"feature_code" => ft123c.code, "feature_name" => ft123c.name, "access" => true},
                                 %{"feature_code" => ft124c.code, "feature_name" => ft124c.name, "access" => true},
                                 %{"feature_code" => ft125c.code, "feature_name" => ft125c.name, "access" => true},
                                 %{"feature_code" => ft126c.code, "feature_name" => ft126c.name, "access" => true},
                                 %{"feature_code" => ft127c.code, "feature_name" => ft127c.name, "access" => true},
                                 %{"feature_code" => ft128c.code, "feature_name" => ft128c.name, "access" => true},
                                 %{"feature_code" => ft129c.code, "feature_name" => ft129c.name, "access" => true}
                                 ]
                             },

                             %{"module_code" => md8c.code,
                              "module_name" => md8c.name,
                              "features" => [
                                  %{"feature_code" => ft130c.code, "feature_name" => ft130c.name, "access" => true},
                                  %{"feature_code" => ft131c.code, "feature_name" => ft131c.name, "access" => true},
                                  %{"feature_code" => ft132c.code, "feature_name" => ft132c.name, "access" => true},
                                  %{"feature_code" => ft133c.code, "feature_name" => ft133c.name, "access" => true},
                                  %{"feature_code" => ft134c.code, "feature_name" => ft134c.name, "access" => true},
                                  ]
                                }
                     ]
                  }


    role_prof3 = %{"name" => "Manager", "code" => "MNGR",
                    "permissions" => [
                      %{"module_code" => md1c.code,
                       "module_name" => md1c.name,
                       "features" => [
                             %{"feature_code" => ft1c.code, "feature_name" => ft1c.name, "access" => false},
                             %{"feature_code" => ft2c.code, "feature_name" => ft2c.name, "access" => false},
                             %{"feature_code" => ft3c.code, "feature_name" => ft3c.name, "access" => false},
                             %{"feature_code" => ft4c.code, "feature_name" => ft4c.name, "access" => false},
                             %{"feature_code" => ft5c.code, "feature_name" => ft5c.name, "access" => false},
                             %{"feature_code" => ft6c.code, "feature_name" => ft6c.name, "access" => false},
                             %{"feature_code" => ft7c.code, "feature_name" => ft7c.name, "access" => false},
                             %{"feature_code" => ft8c.code, "feature_name" => ft8c.name, "access" => false},
                             %{"feature_code" => ft9c.code, "feature_name" => ft9c.name, "access" => false},
                             %{"feature_code" => ft10c.code, "feature_name" => ft10c.name, "access" => false},
                             %{"feature_code" => ft11c.code, "feature_name" => ft11c.name, "access" => false},
                             %{"feature_code" => ft12c.code, "feature_name" => ft12c.name, "access" => false},
                             %{"feature_code" => ft13c.code, "feature_name" => ft13c.name, "access" => false},
                             %{"feature_code" => ft14c.code, "feature_name" => ft14c.name, "access" => false},
                             %{"feature_code" => ft15c.code, "feature_name" => ft15c.name, "access" => false},
                             %{"feature_code" => ft16c.code, "feature_name" => ft16c.name, "access" => true}
                           ]
                       },

                       %{"module_code" => md2c.code,
                        "module_name" => md2c.name,
                        "features" => [
                              %{"feature_code" => ft17c.code, "feature_name" => ft17c.name, "access" => true},
                              %{"feature_code" => ft18c.code, "feature_name" => ft18c.name, "access" => true},
                              %{"feature_code" => ft19c.code, "feature_name" => ft19c.name, "access" => false},
                              %{"feature_code" => ft20c.code, "feature_name" => ft20c.name, "access" => true},
                              %{"feature_code" => ft21c.code, "feature_name" => ft21c.name, "access" => true},
                              %{"feature_code" => ft22c.code, "feature_name" => ft22c.name, "access" => false},
                              %{"feature_code" => ft23c.code, "feature_name" => ft23c.name, "access" => true},
                              %{"feature_code" => ft24c.code, "feature_name" => ft24c.name, "access" => true},
                              %{"feature_code" => ft25c.code, "feature_name" => ft25c.name, "access" => false},
                              %{"feature_code" => ft26c.code, "feature_name" => ft26c.name, "access" => true},
                              %{"feature_code" => ft27c.code, "feature_name" => ft27c.name, "access" => true},
                              %{"feature_code" => ft28c.code, "feature_name" => ft28c.name, "access" => false},
                              %{"feature_code" => ft29c.code, "feature_name" => ft29c.name, "access" => true},
                              %{"feature_code" => ft30c.code, "feature_name" => ft30c.name, "access" => true},
                              %{"feature_code" => ft31c.code, "feature_name" => ft31c.name, "access" => false},
                              %{"feature_code" => ft32c.code, "feature_name" => ft32c.name, "access" => true},
                              %{"feature_code" => ft33c.code, "feature_name" => ft33c.name, "access" => true}
                            ]
                        },

                        %{"module_code" => md3c.code,
                         "module_name" => md3c.name,
                         "features" => [
                                  %{"feature_code" => ft34c.code, "feature_name" => ft34c.name, "access" => false},
                                  %{"feature_code" => ft35c.code, "feature_name" => ft35c.name, "access" => true},
                                  %{"feature_code" => ft36c.code, "feature_name" => ft36c.name, "access" => false},
                                  %{"feature_code" => ft37c.code, "feature_name" => ft37c.name, "access" => true},
                                  %{"feature_code" => ft38c.code, "feature_name" => ft38c.name, "access" => true},
                                  %{"feature_code" => ft39c.code, "feature_name" => ft39c.name, "access" => true},
                                  %{"feature_code" => ft40c.code, "feature_name" => ft40c.name, "access" => true},
                                  %{"feature_code" => ft41c.code, "feature_name" => ft41c.name, "access" => true},
                                  %{"feature_code" => ft42c.code, "feature_name" => ft42c.name, "access" => true},
                                  %{"feature_code" => ft43c.code, "feature_name" => ft43c.name, "access" => true},
                                  %{"feature_code" => ft44c.code, "feature_name" => ft44c.name, "access" => true},
                                  %{"feature_code" => ft45c.code, "feature_name" => ft45c.name, "access" => true},
                                  %{"feature_code" => ft46c.code, "feature_name" => ft46c.name, "access" => true},
                                  %{"feature_code" => ft47c.code, "feature_name" => ft47c.name, "access" => true},
                                  %{"feature_code" => ft48c.code, "feature_name" => ft48c.name, "access" => true},
                                  %{"feature_code" => ft49c.code, "feature_name" => ft49c.name, "access" => true},
                                  %{"feature_code" => ft50c.code, "feature_name" => ft50c.name, "access" => true},
                                  %{"feature_code" => ft51c.code, "feature_name" => ft51c.name, "access" => true},
                                  %{"feature_code" => ft52c.code, "feature_name" => ft52c.name, "access" => true},
                                  %{"feature_code" => ft53c.code, "feature_name" => ft53c.name, "access" => true},
                                  %{"feature_code" => ft54c.code, "feature_name" => ft54c.name, "access" => true},
                                  %{"feature_code" => ft55c.code, "feature_name" => ft55c.name, "access" => true},
                                  %{"feature_code" => ft56c.code, "feature_name" => ft56c.name, "access" => true},
                                  %{"feature_code" => ft57c.code, "feature_name" => ft57c.name, "access" => true},
                                  %{"feature_code" => ft58c.code, "feature_name" => ft58c.name, "access" => true},
                                  %{"feature_code" => ft59c.code, "feature_name" => ft59c.name, "access" => true},
                                  %{"feature_code" => ft60c.code, "feature_name" => ft60c.name, "access" => true},
                                  %{"feature_code" => ft61c.code, "feature_name" => ft61c.name, "access" => false},
                                  %{"feature_code" => ft62c.code, "feature_name" => ft62c.name, "access" => true},
                                  %{"feature_code" => ft63c.code, "feature_name" => ft63c.name, "access" => true},
                                  %{"feature_code" => ft64c.code, "feature_name" => ft64c.name, "access" => true},
                                  %{"feature_code" => ft65c.code, "feature_name" => ft65c.name, "access" => true},
                                  %{"feature_code" => ft66c.code, "feature_name" => ft66c.name, "access" => true},
                                  %{"feature_code" => ft67c.code, "feature_name" => ft67c.name, "access" => false},
                                  %{"feature_code" => ft68c.code, "feature_name" => ft68c.name, "access" => true},
                                  %{"feature_code" => ft69c.code, "feature_name" => ft69c.name, "access" => true},
                                  %{"feature_code" => ft70c.code, "feature_name" => ft70c.name, "access" => true},
                                  %{"feature_code" => ft71c.code, "feature_name" => ft71c.name, "access" => true},
                                  %{"feature_code" => ft72c.code, "feature_name" => ft72c.name, "access" => true},
                                  %{"feature_code" => ft73c.code, "feature_name" => ft73c.name, "access" => false},
                                  %{"feature_code" => ft74c.code, "feature_name" => ft74c.name, "access" => true},
                                  %{"feature_code" => ft75c.code, "feature_name" => ft75c.name, "access" => true},
                                  %{"feature_code" => ft76c.code, "feature_name" => ft76c.name, "access" => true}
                             ]
                         },

                         %{"module_code" => md4c.code,
                          "module_name" => md4c.name,
                          "features" => [
                                %{"feature_code" => ft77c.code, "feature_name" => ft77c.name, "access" => true},
                                %{"feature_code" => ft78c.code, "feature_name" => ft78c.name, "access" => true},
                                %{"feature_code" => ft79c.code, "feature_name" => ft79c.name, "access" => false},
                                %{"feature_code" => ft80c.code, "feature_name" => ft80c.name, "access" => true},
                                %{"feature_code" => ft81c.code, "feature_name" => ft81c.name, "access" => true},
                                %{"feature_code" => ft82c.code, "feature_name" => ft82c.name, "access" => true},
                                %{"feature_code" => ft83c.code, "feature_name" => ft83c.name, "access" => true},
                                %{"feature_code" => ft84c.code, "feature_name" => ft84c.name, "access" => false},
                                %{"feature_code" => ft85c.code, "feature_name" => ft85c.name, "access" => true},
                                %{"feature_code" => ft86c.code, "feature_name" => ft86c.name, "access" => true},
                                %{"feature_code" => ft87c.code, "feature_name" => ft87c.name, "access" => true},
                                %{"feature_code" => ft88c.code, "feature_name" => ft88c.name, "access" => true},
                                %{"feature_code" => ft89c.code, "feature_name" => ft89c.name, "access" => false},
                                %{"feature_code" => ft90c.code, "feature_name" => ft90c.name, "access" => true},
                                %{"feature_code" => ft91c.code, "feature_name" => ft91c.name, "access" => true},
                                %{"feature_code" => ft92c.code, "feature_name" => ft92c.name, "access" => true},
                                %{"feature_code" => ft93c.code, "feature_name" => ft93c.name, "access" => true},
                                %{"feature_code" => ft94c.code, "feature_name" => ft94c.name, "access" => false},
                                %{"feature_code" => ft95c.code, "feature_name" => ft95c.name, "access" => true},
                                %{"feature_code" => ft96c.code, "feature_name" => ft96c.name, "access" => true}
                              ]
                          },

                          %{"module_code" => md5c.code,
                           "module_name" => md5c.name,
                           "features" => [
                                %{"feature_code" => ft97c.code, "feature_name" => ft97c.name, "access" => true},
                                %{"feature_code" => ft98c.code, "feature_name" => ft98c.name, "access" => true},
                                %{"feature_code" => ft99c.code, "feature_name" => ft99c.name, "access" => true},
                                %{"feature_code" => ft100c.code, "feature_name" => ft100c.name, "access" => true},
                                %{"feature_code" => ft101c.code, "feature_name" => ft101c.name, "access" => true},
                                %{"feature_code" => ft102c.code, "feature_name" => ft102c.name, "access" => true},
                                %{"feature_code" => ft103c.code, "feature_name" => ft103c.name, "access" => true},
                                %{"feature_code" => ft104c.code, "feature_name" => ft104c.name, "access" => true},
                                %{"feature_code" => ft105c.code, "feature_name" => ft105c.name, "access" => true},
                                %{"feature_code" => ft106c.code, "feature_name" => ft106c.name, "access" => true}
                               ]
                           },

                           %{"module_code" => md6c.code,
                            "module_name" => md6c.name,
                            "features" => [
                                %{"feature_code" => ft107c.code, "feature_name" => ft107c.name, "access" => true},
                                %{"feature_code" => ft108c.code, "feature_name" => ft108c.name, "access" => true},
                                %{"feature_code" => ft109c.code, "feature_name" => ft109c.name, "access" => true},
                                %{"feature_code" => ft110c.code, "feature_name" => ft110c.name, "access" => true},
                                %{"feature_code" => ft111c.code, "feature_name" => ft111c.name, "access" => true},
                                %{"feature_code" => ft112c.code, "feature_name" => ft112c.name, "access" => true},
                                %{"feature_code" => ft113c.code, "feature_name" => ft113c.name, "access" => true},
                                %{"feature_code" => ft114c.code, "feature_name" => ft114c.name, "access" => true},
                                %{"feature_code" => ft115c.code, "feature_name" => ft115c.name, "access" => true}
                                ]
                            },

                            %{"module_code" => md7c.code,
                             "module_name" => md7c.name,
                             "features" => [
                                 %{"feature_code" => ft116c.code, "feature_name" => ft116c.name, "access" => true},
                                 %{"feature_code" => ft117c.code, "feature_name" => ft117c.name, "access" => true},
                                 %{"feature_code" => ft118c.code, "feature_name" => ft118c.name, "access" => false},
                                 %{"feature_code" => ft119c.code, "feature_name" => ft119c.name, "access" => true},
                                 %{"feature_code" => ft120c.code, "feature_name" => ft120c.name, "access" => false},
                                 %{"feature_code" => ft121c.code, "feature_name" => ft121c.name, "access" => true},
                                 %{"feature_code" => ft122c.code, "feature_name" => ft122c.name, "access" => true},
                                 %{"feature_code" => ft123c.code, "feature_name" => ft123c.name, "access" => true},
                                 %{"feature_code" => ft124c.code, "feature_name" => ft124c.name, "access" => true},
                                 %{"feature_code" => ft125c.code, "feature_name" => ft125c.name, "access" => false},
                                 %{"feature_code" => ft126c.code, "feature_name" => ft126c.name, "access" => false},
                                 %{"feature_code" => ft127c.code, "feature_name" => ft127c.name, "access" => true},
                                 %{"feature_code" => ft128c.code, "feature_name" => ft128c.name, "access" => true},
                                 %{"feature_code" => ft129c.code, "feature_name" => ft129c.name, "access" => true}
                                 ]
                             },

                             %{"module_code" => md8c.code,
                              "module_name" => md8c.name,
                              "features" => [
                                  %{"feature_code" => ft130c.code, "feature_name" => ft130c.name, "access" => true},
                                  %{"feature_code" => ft131c.code, "feature_name" => ft131c.name, "access" => true},
                                  %{"feature_code" => ft132c.code, "feature_name" => ft132c.name, "access" => true},
                                  %{"feature_code" => ft133c.code, "feature_name" => ft133c.name, "access" => true},
                                  %{"feature_code" => ft134c.code, "feature_name" => ft134c.name, "access" => true},
                                  ]
                                }
                     ]
                  }

    role_prof4 = %{"name" => "Supervisor", "code" => "SPVI",
                    "permissions" => [
                      %{"module_code" => md1c.code,
                       "module_name" => md1c.name,
                       "features" => [
                             %{"feature_code" => ft1c.code, "feature_name" => ft1c.name, "access" => false},
                             %{"feature_code" => ft2c.code, "feature_name" => ft2c.name, "access" => false},
                             %{"feature_code" => ft3c.code, "feature_name" => ft3c.name, "access" => false},
                             %{"feature_code" => ft4c.code, "feature_name" => ft4c.name, "access" => false},
                             %{"feature_code" => ft5c.code, "feature_name" => ft5c.name, "access" => false},
                             %{"feature_code" => ft6c.code, "feature_name" => ft6c.name, "access" => false},
                             %{"feature_code" => ft7c.code, "feature_name" => ft7c.name, "access" => false},
                             %{"feature_code" => ft8c.code, "feature_name" => ft8c.name, "access" => false},
                             %{"feature_code" => ft9c.code, "feature_name" => ft9c.name, "access" => false},
                             %{"feature_code" => ft10c.code, "feature_name" => ft10c.name, "access" => false},
                             %{"feature_code" => ft11c.code, "feature_name" => ft11c.name, "access" => false},
                             %{"feature_code" => ft12c.code, "feature_name" => ft12c.name, "access" => false},
                             %{"feature_code" => ft13c.code, "feature_name" => ft13c.name, "access" => false},
                             %{"feature_code" => ft14c.code, "feature_name" => ft14c.name, "access" => false},
                             %{"feature_code" => ft15c.code, "feature_name" => ft15c.name, "access" => false},
                             %{"feature_code" => ft16c.code, "feature_name" => ft16c.name, "access" => true}
                           ]
                       },

                       %{"module_code" => md2c.code,
                        "module_name" => md2c.name,
                        "features" => [
                              %{"feature_code" => ft17c.code, "feature_name" => ft17c.name, "access" => false},
                              %{"feature_code" => ft18c.code, "feature_name" => ft18c.name, "access" => false},
                              %{"feature_code" => ft19c.code, "feature_name" => ft19c.name, "access" => false},
                              %{"feature_code" => ft20c.code, "feature_name" => ft20c.name, "access" => true},
                              %{"feature_code" => ft21c.code, "feature_name" => ft21c.name, "access" => true},
                              %{"feature_code" => ft22c.code, "feature_name" => ft22c.name, "access" => false},
                              %{"feature_code" => ft23c.code, "feature_name" => ft23c.name, "access" => false},
                              %{"feature_code" => ft24c.code, "feature_name" => ft24c.name, "access" => false},
                              %{"feature_code" => ft25c.code, "feature_name" => ft25c.name, "access" => false},
                              %{"feature_code" => ft26c.code, "feature_name" => ft26c.name, "access" => true},
                              %{"feature_code" => ft27c.code, "feature_name" => ft27c.name, "access" => true},
                              %{"feature_code" => ft28c.code, "feature_name" => ft28c.name, "access" => false},
                              %{"feature_code" => ft29c.code, "feature_name" => ft29c.name, "access" => false},
                              %{"feature_code" => ft30c.code, "feature_name" => ft30c.name, "access" => false},
                              %{"feature_code" => ft31c.code, "feature_name" => ft31c.name, "access" => false},
                              %{"feature_code" => ft32c.code, "feature_name" => ft32c.name, "access" => true},
                              %{"feature_code" => ft33c.code, "feature_name" => ft33c.name, "access" => false}
                            ]
                        },

                        %{"module_code" => md3c.code,
                         "module_name" => md3c.name,
                         "features" => [
                                  %{"feature_code" => ft34c.code, "feature_name" => ft34c.name, "access" => false},
                                  %{"feature_code" => ft35c.code, "feature_name" => ft35c.name, "access" => false},
                                  %{"feature_code" => ft36c.code, "feature_name" => ft36c.name, "access" => false},
                                  %{"feature_code" => ft37c.code, "feature_name" => ft37c.name, "access" => true},
                                  %{"feature_code" => ft38c.code, "feature_name" => ft38c.name, "access" => true},
                                  %{"feature_code" => ft39c.code, "feature_name" => ft39c.name, "access" => true},
                                  %{"feature_code" => ft40c.code, "feature_name" => ft40c.name, "access" => true},
                                  %{"feature_code" => ft41c.code, "feature_name" => ft41c.name, "access" => false},
                                  %{"feature_code" => ft42c.code, "feature_name" => ft42c.name, "access" => true},
                                  %{"feature_code" => ft43c.code, "feature_name" => ft43c.name, "access" => true},
                                  %{"feature_code" => ft44c.code, "feature_name" => ft44c.name, "access" => true},
                                  %{"feature_code" => ft45c.code, "feature_name" => ft45c.name, "access" => true},
                                  %{"feature_code" => ft46c.code, "feature_name" => ft46c.name, "access" => true},
                                  %{"feature_code" => ft47c.code, "feature_name" => ft47c.name, "access" => false},
                                  %{"feature_code" => ft48c.code, "feature_name" => ft48c.name, "access" => true},
                                  %{"feature_code" => ft49c.code, "feature_name" => ft49c.name, "access" => true},
                                  %{"feature_code" => ft50c.code, "feature_name" => ft50c.name, "access" => true},
                                  %{"feature_code" => ft51c.code, "feature_name" => ft51c.name, "access" => true},
                                  %{"feature_code" => ft52c.code, "feature_name" => ft52c.name, "access" => true},
                                  %{"feature_code" => ft53c.code, "feature_name" => ft53c.name, "access" => true},
                                  %{"feature_code" => ft54c.code, "feature_name" => ft54c.name, "access" => true},
                                  %{"feature_code" => ft55c.code, "feature_name" => ft55c.name, "access" => false},
                                  %{"feature_code" => ft56c.code, "feature_name" => ft56c.name, "access" => true},
                                  %{"feature_code" => ft57c.code, "feature_name" => ft57c.name, "access" => true},
                                  %{"feature_code" => ft58c.code, "feature_name" => ft58c.name, "access" => true},
                                  %{"feature_code" => ft59c.code, "feature_name" => ft59c.name, "access" => true},
                                  %{"feature_code" => ft60c.code, "feature_name" => ft60c.name, "access" => true},
                                  %{"feature_code" => ft61c.code, "feature_name" => ft61c.name, "access" => false},
                                  %{"feature_code" => ft62c.code, "feature_name" => ft62c.name, "access" => true},
                                  %{"feature_code" => ft63c.code, "feature_name" => ft63c.name, "access" => true},
                                  %{"feature_code" => ft64c.code, "feature_name" => ft64c.name, "access" => true},
                                  %{"feature_code" => ft65c.code, "feature_name" => ft65c.name, "access" => true},
                                  %{"feature_code" => ft66c.code, "feature_name" => ft66c.name, "access" => true},
                                  %{"feature_code" => ft67c.code, "feature_name" => ft67c.name, "access" => false},
                                  %{"feature_code" => ft68c.code, "feature_name" => ft68c.name, "access" => true},
                                  %{"feature_code" => ft69c.code, "feature_name" => ft69c.name, "access" => true},
                                  %{"feature_code" => ft70c.code, "feature_name" => ft70c.name, "access" => true},
                                  %{"feature_code" => ft71c.code, "feature_name" => ft71c.name, "access" => false},
                                  %{"feature_code" => ft72c.code, "feature_name" => ft72c.name, "access" => true},
                                  %{"feature_code" => ft73c.code, "feature_name" => ft73c.name, "access" => false},
                                  %{"feature_code" => ft74c.code, "feature_name" => ft74c.name, "access" => true},
                                  %{"feature_code" => ft75c.code, "feature_name" => ft75c.name, "access" => true},
                                  %{"feature_code" => ft76c.code, "feature_name" => ft76c.name, "access" => true}
                             ]
                         },

                         %{"module_code" => md4c.code,
                          "module_name" => md4c.name,
                          "features" => [
                                %{"feature_code" => ft77c.code, "feature_name" => ft77c.name, "access" => false},
                                %{"feature_code" => ft78c.code, "feature_name" => ft78c.name, "access" => false},
                                %{"feature_code" => ft79c.code, "feature_name" => ft79c.name, "access" => false},
                                %{"feature_code" => ft80c.code, "feature_name" => ft80c.name, "access" => true},
                                %{"feature_code" => ft81c.code, "feature_name" => ft81c.name, "access" => true},
                                %{"feature_code" => ft82c.code, "feature_name" => ft82c.name, "access" => false},
                                %{"feature_code" => ft83c.code, "feature_name" => ft83c.name, "access" => false},
                                %{"feature_code" => ft84c.code, "feature_name" => ft84c.name, "access" => false},
                                %{"feature_code" => ft85c.code, "feature_name" => ft85c.name, "access" => true},
                                %{"feature_code" => ft86c.code, "feature_name" => ft86c.name, "access" => true},
                                %{"feature_code" => ft87c.code, "feature_name" => ft87c.name, "access" => false},
                                %{"feature_code" => ft88c.code, "feature_name" => ft88c.name, "access" => true},
                                %{"feature_code" => ft89c.code, "feature_name" => ft89c.name, "access" => false},
                                %{"feature_code" => ft90c.code, "feature_name" => ft90c.name, "access" => true},
                                %{"feature_code" => ft91c.code, "feature_name" => ft91c.name, "access" => true},
                                %{"feature_code" => ft92c.code, "feature_name" => ft92c.name, "access" => false},
                                %{"feature_code" => ft93c.code, "feature_name" => ft93c.name, "access" => false},
                                %{"feature_code" => ft94c.code, "feature_name" => ft94c.name, "access" => false},
                                %{"feature_code" => ft95c.code, "feature_name" => ft95c.name, "access" => true},
                                %{"feature_code" => ft96c.code, "feature_name" => ft96c.name, "access" => true}
                              ]
                          },

                          %{"module_code" => md5c.code,
                           "module_name" => md5c.name,
                           "features" => [
                                %{"feature_code" => ft97c.code, "feature_name" => ft97c.name, "access" => true},
                                %{"feature_code" => ft98c.code, "feature_name" => ft98c.name, "access" => true},
                                %{"feature_code" => ft99c.code, "feature_name" => ft99c.name, "access" => true},
                                %{"feature_code" => ft100c.code, "feature_name" => ft100c.name, "access" => true},
                                %{"feature_code" => ft101c.code, "feature_name" => ft101c.name, "access" => true},
                                %{"feature_code" => ft102c.code, "feature_name" => ft102c.name, "access" => true},
                                %{"feature_code" => ft103c.code, "feature_name" => ft103c.name, "access" => true},
                                %{"feature_code" => ft104c.code, "feature_name" => ft104c.name, "access" => true},
                                %{"feature_code" => ft105c.code, "feature_name" => ft105c.name, "access" => true},
                                %{"feature_code" => ft106c.code, "feature_name" => ft106c.name, "access" => true}
                               ]
                           },

                           %{"module_code" => md6c.code,
                            "module_name" => md6c.name,
                            "features" => [
                                %{"feature_code" => ft107c.code, "feature_name" => ft107c.name, "access" => true},
                                %{"feature_code" => ft108c.code, "feature_name" => ft108c.name, "access" => true},
                                %{"feature_code" => ft109c.code, "feature_name" => ft109c.name, "access" => false},
                                %{"feature_code" => ft110c.code, "feature_name" => ft110c.name, "access" => true},
                                %{"feature_code" => ft111c.code, "feature_name" => ft111c.name, "access" => true},
                                %{"feature_code" => ft112c.code, "feature_name" => ft112c.name, "access" => true},
                                %{"feature_code" => ft113c.code, "feature_name" => ft113c.name, "access" => true},
                                %{"feature_code" => ft114c.code, "feature_name" => ft114c.name, "access" => true},
                                %{"feature_code" => ft115c.code, "feature_name" => ft115c.name, "access" => true}
                                ]
                            },

                            %{"module_code" => md7c.code,
                             "module_name" => md7c.name,
                             "features" => [
                                 %{"feature_code" => ft116c.code, "feature_name" => ft116c.name, "access" => true},
                                 %{"feature_code" => ft117c.code, "feature_name" => ft117c.name, "access" => false},
                                 %{"feature_code" => ft118c.code, "feature_name" => ft118c.name, "access" => true},
                                 %{"feature_code" => ft119c.code, "feature_name" => ft119c.name, "access" => true},
                                 %{"feature_code" => ft120c.code, "feature_name" => ft120c.name, "access" => false},
                                 %{"feature_code" => ft121c.code, "feature_name" => ft121c.name, "access" => true},
                                 %{"feature_code" => ft122c.code, "feature_name" => ft122c.name, "access" => true},
                                 %{"feature_code" => ft123c.code, "feature_name" => ft123c.name, "access" => false},
                                 %{"feature_code" => ft124c.code, "feature_name" => ft124c.name, "access" => false},
                                 %{"feature_code" => ft125c.code, "feature_name" => ft125c.name, "access" => false},
                                 %{"feature_code" => ft126c.code, "feature_name" => ft126c.name, "access" => false},
                                 %{"feature_code" => ft127c.code, "feature_name" => ft127c.name, "access" => true},
                                 %{"feature_code" => ft128c.code, "feature_name" => ft128c.name, "access" => true},
                                 %{"feature_code" => ft129c.code, "feature_name" => ft129c.name, "access" => true}
                                 ]
                             },

                             %{"module_code" => md8c.code,
                              "module_name" => md8c.name,
                              "features" => [
                                  %{"feature_code" => ft130c.code, "feature_name" => ft130c.name, "access" => true},
                                  %{"feature_code" => ft131c.code, "feature_name" => ft131c.name, "access" => true},
                                  %{"feature_code" => ft132c.code, "feature_name" => ft132c.name, "access" => false},
                                  %{"feature_code" => ft133c.code, "feature_name" => ft133c.name, "access" => false},
                                  %{"feature_code" => ft134c.code, "feature_name" => ft134c.name, "access" => true},
                                  ]
                                }
                     ]
                  }

    role_prof5 = %{"name" => "Technician", "code" => "TECH",
                    "permissions" => [
                      %{"module_code" => md1c.code,
                       "module_name" => md1c.name,
                       "features" => [
                             %{"feature_code" => ft1c.code, "feature_name" => ft1c.name, "access" => false},
                             %{"feature_code" => ft2c.code, "feature_name" => ft2c.name, "access" => false},
                             %{"feature_code" => ft3c.code, "feature_name" => ft3c.name, "access" => false},
                             %{"feature_code" => ft4c.code, "feature_name" => ft4c.name, "access" => false},
                             %{"feature_code" => ft5c.code, "feature_name" => ft5c.name, "access" => false},
                             %{"feature_code" => ft6c.code, "feature_name" => ft6c.name, "access" => false},
                             %{"feature_code" => ft7c.code, "feature_name" => ft7c.name, "access" => false},
                             %{"feature_code" => ft8c.code, "feature_name" => ft8c.name, "access" => false},
                             %{"feature_code" => ft9c.code, "feature_name" => ft9c.name, "access" => false},
                             %{"feature_code" => ft10c.code, "feature_name" => ft10c.name, "access" => false},
                             %{"feature_code" => ft11c.code, "feature_name" => ft11c.name, "access" => false},
                             %{"feature_code" => ft12c.code, "feature_name" => ft12c.name, "access" => false},
                             %{"feature_code" => ft13c.code, "feature_name" => ft13c.name, "access" => false},
                             %{"feature_code" => ft14c.code, "feature_name" => ft14c.name, "access" => false},
                             %{"feature_code" => ft15c.code, "feature_name" => ft15c.name, "access" => false},
                             %{"feature_code" => ft16c.code, "feature_name" => ft16c.name, "access" => true}
                           ]
                       },

                       %{"module_code" => md2c.code,
                        "module_name" => md2c.name,
                        "features" => [
                              %{"feature_code" => ft17c.code, "feature_name" => ft17c.name, "access" => false},
                              %{"feature_code" => ft18c.code, "feature_name" => ft18c.name, "access" => false},
                              %{"feature_code" => ft19c.code, "feature_name" => ft19c.name, "access" => false},
                              %{"feature_code" => ft20c.code, "feature_name" => ft20c.name, "access" => true},
                              %{"feature_code" => ft21c.code, "feature_name" => ft21c.name, "access" => true},
                              %{"feature_code" => ft22c.code, "feature_name" => ft22c.name, "access" => false},
                              %{"feature_code" => ft23c.code, "feature_name" => ft23c.name, "access" => false},
                              %{"feature_code" => ft24c.code, "feature_name" => ft24c.name, "access" => false},
                              %{"feature_code" => ft25c.code, "feature_name" => ft25c.name, "access" => false},
                              %{"feature_code" => ft26c.code, "feature_name" => ft26c.name, "access" => true},
                              %{"feature_code" => ft27c.code, "feature_name" => ft27c.name, "access" => true},
                              %{"feature_code" => ft28c.code, "feature_name" => ft28c.name, "access" => false},
                              %{"feature_code" => ft29c.code, "feature_name" => ft29c.name, "access" => false},
                              %{"feature_code" => ft30c.code, "feature_name" => ft30c.name, "access" => false},
                              %{"feature_code" => ft31c.code, "feature_name" => ft31c.name, "access" => false},
                              %{"feature_code" => ft32c.code, "feature_name" => ft32c.name, "access" => true},
                              %{"feature_code" => ft33c.code, "feature_name" => ft33c.name, "access" => false}
                            ]
                        },

                        %{"module_code" => md3c.code,
                         "module_name" => md3c.name,
                         "features" => [
                                  %{"feature_code" => ft34c.code, "feature_name" => ft34c.name, "access" => false},
                                  %{"feature_code" => ft35c.code, "feature_name" => ft35c.name, "access" => false},
                                  %{"feature_code" => ft36c.code, "feature_name" => ft36c.name, "access" => false},
                                  %{"feature_code" => ft37c.code, "feature_name" => ft37c.name, "access" => true},
                                  %{"feature_code" => ft38c.code, "feature_name" => ft38c.name, "access" => true},
                                  %{"feature_code" => ft39c.code, "feature_name" => ft39c.name, "access" => false},
                                  %{"feature_code" => ft40c.code, "feature_name" => ft40c.name, "access" => false},
                                  %{"feature_code" => ft41c.code, "feature_name" => ft41c.name, "access" => false},
                                  %{"feature_code" => ft42c.code, "feature_name" => ft42c.name, "access" => true},
                                  %{"feature_code" => ft43c.code, "feature_name" => ft43c.name, "access" => true},
                                  %{"feature_code" => ft44c.code, "feature_name" => ft44c.name, "access" => false},
                                  %{"feature_code" => ft45c.code, "feature_name" => ft45c.name, "access" => false},
                                  %{"feature_code" => ft46c.code, "feature_name" => ft46c.name, "access" => false},
                                  %{"feature_code" => ft47c.code, "feature_name" => ft47c.name, "access" => false},
                                  %{"feature_code" => ft48c.code, "feature_name" => ft48c.name, "access" => true},
                                  %{"feature_code" => ft49c.code, "feature_name" => ft49c.name, "access" => true},
                                  %{"feature_code" => ft50c.code, "feature_name" => ft50c.name, "access" => true},
                                  %{"feature_code" => ft51c.code, "feature_name" => ft51c.name, "access" => true},
                                  %{"feature_code" => ft52c.code, "feature_name" => ft52c.name, "access" => true},
                                  %{"feature_code" => ft53c.code, "feature_name" => ft53c.name, "access" => false},
                                  %{"feature_code" => ft54c.code, "feature_name" => ft54c.name, "access" => false},
                                  %{"feature_code" => ft55c.code, "feature_name" => ft55c.name, "access" => false},
                                  %{"feature_code" => ft56c.code, "feature_name" => ft56c.name, "access" => true},
                                  %{"feature_code" => ft57c.code, "feature_name" => ft57c.name, "access" => true},
                                  %{"feature_code" => ft58c.code, "feature_name" => ft58c.name, "access" => false},
                                  %{"feature_code" => ft59c.code, "feature_name" => ft59c.name, "access" => false},
                                  %{"feature_code" => ft60c.code, "feature_name" => ft60c.name, "access" => false},
                                  %{"feature_code" => ft61c.code, "feature_name" => ft61c.name, "access" => false},
                                  %{"feature_code" => ft62c.code, "feature_name" => ft62c.name, "access" => true},
                                  %{"feature_code" => ft63c.code, "feature_name" => ft63c.name, "access" => true},
                                  %{"feature_code" => ft64c.code, "feature_name" => ft64c.name, "access" => false},
                                  %{"feature_code" => ft65c.code, "feature_name" => ft65c.name, "access" => false},
                                  %{"feature_code" => ft66c.code, "feature_name" => ft66c.name, "access" => false},
                                  %{"feature_code" => ft67c.code, "feature_name" => ft67c.name, "access" => false},
                                  %{"feature_code" => ft68c.code, "feature_name" => ft68c.name, "access" => true},
                                  %{"feature_code" => ft69c.code, "feature_name" => ft69c.name, "access" => true},
                                  %{"feature_code" => ft70c.code, "feature_name" => ft70c.name, "access" => false},
                                  %{"feature_code" => ft71c.code, "feature_name" => ft71c.name, "access" => false},
                                  %{"feature_code" => ft72c.code, "feature_name" => ft72c.name, "access" => false},
                                  %{"feature_code" => ft73c.code, "feature_name" => ft73c.name, "access" => false},
                                  %{"feature_code" => ft74c.code, "feature_name" => ft74c.name, "access" => true},
                                  %{"feature_code" => ft75c.code, "feature_name" => ft75c.name, "access" => true},
                                  %{"feature_code" => ft76c.code, "feature_name" => ft76c.name, "access" => false}
                             ]
                         },

                         %{"module_code" => md4c.code,
                          "module_name" => md4c.name,
                          "features" => [
                                %{"feature_code" => ft77c.code, "feature_name" => ft77c.name, "access" => false},
                                %{"feature_code" => ft78c.code, "feature_name" => ft78c.name, "access" => false},
                                %{"feature_code" => ft79c.code, "feature_name" => ft79c.name, "access" => false},
                                %{"feature_code" => ft80c.code, "feature_name" => ft80c.name, "access" => false},
                                %{"feature_code" => ft81c.code, "feature_name" => ft81c.name, "access" => true},
                                %{"feature_code" => ft82c.code, "feature_name" => ft82c.name, "access" => false},
                                %{"feature_code" => ft83c.code, "feature_name" => ft83c.name, "access" => false},
                                %{"feature_code" => ft84c.code, "feature_name" => ft84c.name, "access" => false},
                                %{"feature_code" => ft85c.code, "feature_name" => ft85c.name, "access" => false},
                                %{"feature_code" => ft86c.code, "feature_name" => ft86c.name, "access" => true},
                                %{"feature_code" => ft87c.code, "feature_name" => ft87c.name, "access" => false},
                                %{"feature_code" => ft88c.code, "feature_name" => ft88c.name, "access" => false},
                                %{"feature_code" => ft89c.code, "feature_name" => ft89c.name, "access" => false},
                                %{"feature_code" => ft90c.code, "feature_name" => ft90c.name, "access" => false},
                                %{"feature_code" => ft91c.code, "feature_name" => ft91c.name, "access" => true},
                                %{"feature_code" => ft92c.code, "feature_name" => ft92c.name, "access" => false},
                                %{"feature_code" => ft93c.code, "feature_name" => ft93c.name, "access" => false},
                                %{"feature_code" => ft94c.code, "feature_name" => ft94c.name, "access" => false},
                                %{"feature_code" => ft95c.code, "feature_name" => ft95c.name, "access" => false},
                                %{"feature_code" => ft96c.code, "feature_name" => ft96c.name, "access" => true}
                              ]
                          },

                          %{"module_code" => md5c.code,
                           "module_name" => md5c.name,
                           "features" => [
                                %{"feature_code" => ft97c.code, "feature_name" => ft97c.name, "access" => false},
                                %{"feature_code" => ft98c.code, "feature_name" => ft98c.name, "access" => false},
                                %{"feature_code" => ft99c.code, "feature_name" => ft99c.name, "access" => false},
                                %{"feature_code" => ft100c.code, "feature_name" => ft100c.name, "access" => true},
                                %{"feature_code" => ft101c.code, "feature_name" => ft101c.name, "access" => true},
                                %{"feature_code" => ft102c.code, "feature_name" => ft102c.name, "access" => false},
                                %{"feature_code" => ft103c.code, "feature_name" => ft103c.name, "access" => false},
                                %{"feature_code" => ft104c.code, "feature_name" => ft104c.name, "access" => false},
                                %{"feature_code" => ft105c.code, "feature_name" => ft105c.name, "access" => true},
                                %{"feature_code" => ft106c.code, "feature_name" => ft106c.name, "access" => true}
                               ]
                           },

                           %{"module_code" => md6c.code,
                            "module_name" => md6c.name,
                            "features" => [
                                %{"feature_code" => ft107c.code, "feature_name" => ft107c.name, "access" => true},
                                %{"feature_code" => ft108c.code, "feature_name" => ft108c.name, "access" => false},
                                %{"feature_code" => ft109c.code, "feature_name" => ft109c.name, "access" => false},
                                %{"feature_code" => ft110c.code, "feature_name" => ft110c.name, "access" => false},
                                %{"feature_code" => ft111c.code, "feature_name" => ft111c.name, "access" => true},
                                %{"feature_code" => ft112c.code, "feature_name" => ft112c.name, "access" => true},
                                %{"feature_code" => ft113c.code, "feature_name" => ft113c.name, "access" => false},
                                %{"feature_code" => ft114c.code, "feature_name" => ft114c.name, "access" => false},
                                %{"feature_code" => ft115c.code, "feature_name" => ft115c.name, "access" => true}
                                ]
                            },

                            %{"module_code" => md7c.code,
                             "module_name" => md7c.name,
                             "features" => [
                                 %{"feature_code" => ft116c.code, "feature_name" => ft116c.name, "access" => true},
                                 %{"feature_code" => ft117c.code, "feature_name" => ft117c.name, "access" => false},
                                 %{"feature_code" => ft118c.code, "feature_name" => ft118c.name, "access" => false},
                                 %{"feature_code" => ft119c.code, "feature_name" => ft119c.name, "access" => true},
                                 %{"feature_code" => ft120c.code, "feature_name" => ft120c.name, "access" => false},
                                 %{"feature_code" => ft121c.code, "feature_name" => ft121c.name, "access" => true},
                                 %{"feature_code" => ft122c.code, "feature_name" => ft122c.name, "access" => true},
                                 %{"feature_code" => ft123c.code, "feature_name" => ft123c.name, "access" => false},
                                 %{"feature_code" => ft124c.code, "feature_name" => ft124c.name, "access" => false},
                                 %{"feature_code" => ft125c.code, "feature_name" => ft125c.name, "access" => false},
                                 %{"feature_code" => ft126c.code, "feature_name" => ft126c.name, "access" => false},
                                 %{"feature_code" => ft127c.code, "feature_name" => ft127c.name, "access" => false},
                                 %{"feature_code" => ft128c.code, "feature_name" => ft128c.name, "access" => true},
                                 %{"feature_code" => ft129c.code, "feature_name" => ft129c.name, "access" => true}
                                 ]
                             },

                             %{"module_code" => md8c.code,
                              "module_name" => md8c.name,
                              "features" => [
                                  %{"feature_code" => ft130c.code, "feature_name" => ft130c.name, "access" => false},
                                  %{"feature_code" => ft131c.code, "feature_name" => ft131c.name, "access" => false},
                                  %{"feature_code" => ft132c.code, "feature_name" => ft132c.name, "access" => false},
                                  %{"feature_code" => ft133c.code, "feature_name" => ft133c.name, "access" => false},
                                  %{"feature_code" => ft134c.code, "feature_name" => ft134c.name, "access" => true},
                                  ]
                                }
                     ]
                  }

    role_prof6 = %{"name" => "Others", "code" => "OTHR",
                    "permissions" => [
                      %{"module_code" => md1c.code,
                       "module_name" => md1c.name,
                       "features" => [
                             %{"feature_code" => ft1c.code, "feature_name" => ft1c.name, "access" => false},
                             %{"feature_code" => ft2c.code, "feature_name" => ft2c.name, "access" => false},
                             %{"feature_code" => ft3c.code, "feature_name" => ft3c.name, "access" => false},
                             %{"feature_code" => ft4c.code, "feature_name" => ft4c.name, "access" => false},
                             %{"feature_code" => ft5c.code, "feature_name" => ft5c.name, "access" => false},
                             %{"feature_code" => ft6c.code, "feature_name" => ft6c.name, "access" => false},
                             %{"feature_code" => ft7c.code, "feature_name" => ft7c.name, "access" => false},
                             %{"feature_code" => ft8c.code, "feature_name" => ft8c.name, "access" => false},
                             %{"feature_code" => ft9c.code, "feature_name" => ft9c.name, "access" => false},
                             %{"feature_code" => ft10c.code, "feature_name" => ft10c.name, "access" => false},
                             %{"feature_code" => ft11c.code, "feature_name" => ft11c.name, "access" => false},
                             %{"feature_code" => ft12c.code, "feature_name" => ft12c.name, "access" => false},
                             %{"feature_code" => ft13c.code, "feature_name" => ft13c.name, "access" => false},
                             %{"feature_code" => ft14c.code, "feature_name" => ft14c.name, "access" => false},
                             %{"feature_code" => ft15c.code, "feature_name" => ft15c.name, "access" => false},
                             %{"feature_code" => ft16c.code, "feature_name" => ft16c.name, "access" => true}
                           ]
                       },

                       %{"module_code" => md2c.code,
                        "module_name" => md2c.name,
                        "features" => [
                              %{"feature_code" => ft17c.code, "feature_name" => ft17c.name, "access" => false},
                              %{"feature_code" => ft18c.code, "feature_name" => ft18c.name, "access" => false},
                              %{"feature_code" => ft19c.code, "feature_name" => ft19c.name, "access" => false},
                              %{"feature_code" => ft20c.code, "feature_name" => ft20c.name, "access" => true},
                              %{"feature_code" => ft21c.code, "feature_name" => ft21c.name, "access" => true},
                              %{"feature_code" => ft22c.code, "feature_name" => ft22c.name, "access" => false},
                              %{"feature_code" => ft23c.code, "feature_name" => ft23c.name, "access" => false},
                              %{"feature_code" => ft24c.code, "feature_name" => ft24c.name, "access" => false},
                              %{"feature_code" => ft25c.code, "feature_name" => ft25c.name, "access" => false},
                              %{"feature_code" => ft26c.code, "feature_name" => ft26c.name, "access" => true},
                              %{"feature_code" => ft27c.code, "feature_name" => ft27c.name, "access" => true},
                              %{"feature_code" => ft28c.code, "feature_name" => ft28c.name, "access" => false},
                              %{"feature_code" => ft29c.code, "feature_name" => ft29c.name, "access" => false},
                              %{"feature_code" => ft30c.code, "feature_name" => ft30c.name, "access" => false},
                              %{"feature_code" => ft31c.code, "feature_name" => ft31c.name, "access" => false},
                              %{"feature_code" => ft32c.code, "feature_name" => ft32c.name, "access" => true},
                              %{"feature_code" => ft33c.code, "feature_name" => ft33c.name, "access" => false}
                            ]
                        },

                        %{"module_code" => md3c.code,
                         "module_name" => md3c.name,
                         "features" => [
                                  %{"feature_code" => ft34c.code, "feature_name" => ft34c.name, "access" => false},
                                  %{"feature_code" => ft35c.code, "feature_name" => ft35c.name, "access" => false},
                                  %{"feature_code" => ft36c.code, "feature_name" => ft36c.name, "access" => false},
                                  %{"feature_code" => ft37c.code, "feature_name" => ft37c.name, "access" => true},
                                  %{"feature_code" => ft38c.code, "feature_name" => ft38c.name, "access" => true},
                                  %{"feature_code" => ft39c.code, "feature_name" => ft39c.name, "access" => false},
                                  %{"feature_code" => ft40c.code, "feature_name" => ft40c.name, "access" => false},
                                  %{"feature_code" => ft41c.code, "feature_name" => ft41c.name, "access" => false},
                                  %{"feature_code" => ft42c.code, "feature_name" => ft42c.name, "access" => true},
                                  %{"feature_code" => ft43c.code, "feature_name" => ft43c.name, "access" => true},
                                  %{"feature_code" => ft44c.code, "feature_name" => ft44c.name, "access" => false},
                                  %{"feature_code" => ft45c.code, "feature_name" => ft45c.name, "access" => false},
                                  %{"feature_code" => ft46c.code, "feature_name" => ft46c.name, "access" => false},
                                  %{"feature_code" => ft47c.code, "feature_name" => ft47c.name, "access" => false},
                                  %{"feature_code" => ft48c.code, "feature_name" => ft48c.name, "access" => true},
                                  %{"feature_code" => ft49c.code, "feature_name" => ft49c.name, "access" => false},
                                  %{"feature_code" => ft50c.code, "feature_name" => ft50c.name, "access" => false},
                                  %{"feature_code" => ft51c.code, "feature_name" => ft51c.name, "access" => false},
                                  %{"feature_code" => ft52c.code, "feature_name" => ft52c.name, "access" => true},
                                  %{"feature_code" => ft53c.code, "feature_name" => ft53c.name, "access" => false},
                                  %{"feature_code" => ft54c.code, "feature_name" => ft54c.name, "access" => false},
                                  %{"feature_code" => ft55c.code, "feature_name" => ft55c.name, "access" => false},
                                  %{"feature_code" => ft56c.code, "feature_name" => ft56c.name, "access" => true},
                                  %{"feature_code" => ft57c.code, "feature_name" => ft57c.name, "access" => true},
                                  %{"feature_code" => ft58c.code, "feature_name" => ft58c.name, "access" => false},
                                  %{"feature_code" => ft59c.code, "feature_name" => ft59c.name, "access" => false},
                                  %{"feature_code" => ft60c.code, "feature_name" => ft60c.name, "access" => false},
                                  %{"feature_code" => ft61c.code, "feature_name" => ft61c.name, "access" => false},
                                  %{"feature_code" => ft62c.code, "feature_name" => ft62c.name, "access" => true},
                                  %{"feature_code" => ft63c.code, "feature_name" => ft63c.name, "access" => true},
                                  %{"feature_code" => ft64c.code, "feature_name" => ft64c.name, "access" => false},
                                  %{"feature_code" => ft65c.code, "feature_name" => ft65c.name, "access" => false},
                                  %{"feature_code" => ft66c.code, "feature_name" => ft66c.name, "access" => false},
                                  %{"feature_code" => ft67c.code, "feature_name" => ft67c.name, "access" => false},
                                  %{"feature_code" => ft68c.code, "feature_name" => ft68c.name, "access" => true},
                                  %{"feature_code" => ft69c.code, "feature_name" => ft69c.name, "access" => true},
                                  %{"feature_code" => ft70c.code, "feature_name" => ft70c.name, "access" => false},
                                  %{"feature_code" => ft71c.code, "feature_name" => ft71c.name, "access" => false},
                                  %{"feature_code" => ft72c.code, "feature_name" => ft72c.name, "access" => false},
                                  %{"feature_code" => ft73c.code, "feature_name" => ft73c.name, "access" => false},
                                  %{"feature_code" => ft74c.code, "feature_name" => ft74c.name, "access" => true},
                                  %{"feature_code" => ft75c.code, "feature_name" => ft75c.name, "access" => true},
                                  %{"feature_code" => ft76c.code, "feature_name" => ft76c.name, "access" => false}
                             ]
                         },

                         %{"module_code" => md4c.code,
                          "module_name" => md4c.name,
                          "features" => [
                                %{"feature_code" => ft77c.code, "feature_name" => ft77c.name, "access" => false},
                                %{"feature_code" => ft78c.code, "feature_name" => ft78c.name, "access" => false},
                                %{"feature_code" => ft79c.code, "feature_name" => ft79c.name, "access" => false},
                                %{"feature_code" => ft80c.code, "feature_name" => ft80c.name, "access" => true},
                                %{"feature_code" => ft81c.code, "feature_name" => ft81c.name, "access" => true},
                                %{"feature_code" => ft82c.code, "feature_name" => ft82c.name, "access" => false},
                                %{"feature_code" => ft83c.code, "feature_name" => ft83c.name, "access" => false},
                                %{"feature_code" => ft84c.code, "feature_name" => ft84c.name, "access" => false},
                                %{"feature_code" => ft85c.code, "feature_name" => ft85c.name, "access" => true},
                                %{"feature_code" => ft86c.code, "feature_name" => ft86c.name, "access" => true},
                                %{"feature_code" => ft87c.code, "feature_name" => ft87c.name, "access" => false},
                                %{"feature_code" => ft88c.code, "feature_name" => ft88c.name, "access" => false},
                                %{"feature_code" => ft89c.code, "feature_name" => ft89c.name, "access" => false},
                                %{"feature_code" => ft90c.code, "feature_name" => ft90c.name, "access" => true},
                                %{"feature_code" => ft91c.code, "feature_name" => ft91c.name, "access" => true},
                                %{"feature_code" => ft92c.code, "feature_name" => ft92c.name, "access" => false},
                                %{"feature_code" => ft93c.code, "feature_name" => ft93c.name, "access" => false},
                                %{"feature_code" => ft94c.code, "feature_name" => ft94c.name, "access" => false},
                                %{"feature_code" => ft95c.code, "feature_name" => ft95c.name, "access" => true},
                                %{"feature_code" => ft96c.code, "feature_name" => ft96c.name, "access" => true}
                              ]
                          },

                          %{"module_code" => md5c.code,
                           "module_name" => md5c.name,
                           "features" => [
                                %{"feature_code" => ft97c.code, "feature_name" => ft97c.name, "access" => false},
                                %{"feature_code" => ft98c.code, "feature_name" => ft98c.name, "access" => false},
                                %{"feature_code" => ft99c.code, "feature_name" => ft99c.name, "access" => false},
                                %{"feature_code" => ft100c.code, "feature_name" => ft100c.name, "access" => true},
                                %{"feature_code" => ft101c.code, "feature_name" => ft101c.name, "access" => false},
                                %{"feature_code" => ft102c.code, "feature_name" => ft102c.name, "access" => false},
                                %{"feature_code" => ft103c.code, "feature_name" => ft103c.name, "access" => false},
                                %{"feature_code" => ft104c.code, "feature_name" => ft104c.name, "access" => false},
                                %{"feature_code" => ft105c.code, "feature_name" => ft105c.name, "access" => true},
                                %{"feature_code" => ft106c.code, "feature_name" => ft106c.name, "access" => false}
                               ]
                           },

                           %{"module_code" => md6c.code,
                            "module_name" => md6c.name,
                            "features" => [
                                %{"feature_code" => ft107c.code, "feature_name" => ft107c.name, "access" => true},
                                %{"feature_code" => ft108c.code, "feature_name" => ft108c.name, "access" => false},
                                %{"feature_code" => ft109c.code, "feature_name" => ft109c.name, "access" => false},
                                %{"feature_code" => ft110c.code, "feature_name" => ft110c.name, "access" => false},
                                %{"feature_code" => ft111c.code, "feature_name" => ft111c.name, "access" => false},
                                %{"feature_code" => ft112c.code, "feature_name" => ft112c.name, "access" => false},
                                %{"feature_code" => ft113c.code, "feature_name" => ft113c.name, "access" => false},
                                %{"feature_code" => ft114c.code, "feature_name" => ft114c.name, "access" => false},
                                %{"feature_code" => ft115c.code, "feature_name" => ft115c.name, "access" => true}
                                ]
                            },

                            %{"module_code" => md7c.code,
                             "module_name" => md7c.name,
                             "features" => [
                                 %{"feature_code" => ft116c.code, "feature_name" => ft116c.name, "access" => true},
                                 %{"feature_code" => ft117c.code, "feature_name" => ft117c.name, "access" => false},
                                 %{"feature_code" => ft118c.code, "feature_name" => ft118c.name, "access" => false},
                                 %{"feature_code" => ft119c.code, "feature_name" => ft119c.name, "access" => false},
                                 %{"feature_code" => ft120c.code, "feature_name" => ft120c.name, "access" => false},
                                 %{"feature_code" => ft121c.code, "feature_name" => ft121c.name, "access" => false},
                                 %{"feature_code" => ft122c.code, "feature_name" => ft122c.name, "access" => true},
                                 %{"feature_code" => ft123c.code, "feature_name" => ft123c.name, "access" => false},
                                 %{"feature_code" => ft124c.code, "feature_name" => ft124c.name, "access" => false},
                                 %{"feature_code" => ft125c.code, "feature_name" => ft125c.name, "access" => false},
                                 %{"feature_code" => ft126c.code, "feature_name" => ft126c.name, "access" => false},
                                 %{"feature_code" => ft127c.code, "feature_name" => ft127c.name, "access" => false},
                                 %{"feature_code" => ft128c.code, "feature_name" => ft128c.name, "access" => false},
                                 %{"feature_code" => ft129c.code, "feature_name" => ft129c.name, "access" => true}
                                 ]
                             },

                             %{"module_code" => md8c.code,
                              "module_name" => md8c.name,
                              "features" => [
                                  %{"feature_code" => ft130c.code, "feature_name" => ft130c.name, "access" => true},
                                  %{"feature_code" => ft131c.code, "feature_name" => ft131c.name, "access" => true},
                                  %{"feature_code" => ft132c.code, "feature_name" => ft132c.name, "access" => false},
                                  %{"feature_code" => ft133c.code, "feature_name" => ft133c.name, "access" => false},
                                  %{"feature_code" => ft134c.code, "feature_name" => ft134c.name, "access" => true},
                                  ]
                                }
                     ]
                  }

# {:ok, _role_prof1c} = Staff.create_role_profile(role_prof1, prefix)
{:ok, role_prof2c} = Staff.create_role_profile(role_prof2, prefix)
{:ok, _role_prof3c} = Staff.create_role_profile(role_prof3, prefix)
{:ok, _role_prof4c} = Staff.create_role_profile(role_prof4, prefix)
{:ok, _role_prof5c} = Staff.create_role_profile(role_prof5, prefix)
{:ok, _role_prof6c} = Staff.create_role_profile(role_prof6, prefix)

role_prof2c
  end
end
