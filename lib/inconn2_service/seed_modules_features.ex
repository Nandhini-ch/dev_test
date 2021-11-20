defmodule Inconn2Service.CreateModuleFeatureRoles do
  alias Inconn2Service.Staff

  def seed_features(prefix) do

    ft1 = %{"name" => "Create License", "code" => "CRLI"}
    ft2 = %{"name" => "Edit License", "code" => "EDLI"}
    ft3 = %{"name" => "Delete License", "code" => "DLLI"}
    ft4 = %{"name" => "List view License", "code" => "LVLI"}
    ft5 = %{"name" => "View License", "code" => "VILI"}
    ft6 = %{"name" => "Import License", "code" => "IMLI"}
    ft7 = %{"name" => "Create party", "code" => "CRPT"}
    ft8 = %{"name" => "Edit party", "code" => "EDPT"}
    ft9 = %{"name" => "Delete party", "code" => "DLPT"}
    ft10 = %{"name" => "List view party", "code" => "LVPT"}
    ft11 = %{"name" => "View party", "code" => "VIPT"}
    ft12 = %{"name" => "Import party", "code" => "IMPT"}
    ft13 = %{"name" => "Create Site", "code" => "CRSI"}
    ft14 = %{"name" => "Edit Site", "code" => "EDSI"}
    ft15 = %{"name" => "Delete Site", "code" => "DLSI"}
    ft16 = %{"name" => "View site", "code" => "VISI"}

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

    md1 = %{"name" => "Licensee management", "feature_ids" => [ft1c.id, ft2c.id, ft3c.id, ft4c.id, ft5c.id, ft6c.id, ft7c.id, ft8c.id,
                                                              ft9c.id, ft10c.id, ft11c.id, ft12c.id, ft13c.id, ft14c.id, ft15c.id, ft16c.id]}
    {:ok, md1c} = Staff.create_module(md1, prefix)

    ft17 = %{"name" => "Create Equipment ", "code" => "CREQ"}
    ft18 = %{"name" => "Edit Equipment", "code" => "EDEQ"}
    ft19 = %{"name" => "Delete Equipment", "code" => "DLEQ"}
    ft20 = %{"name" => "List view Equipment", "code" => "LVEQ"}
    ft21 = %{"name" => "View Equipment", "code" => "VIEQ"}
    ft22 = %{"name" => "Import Equipment", "code" => "IMEQ"}
    ft23 = %{"name" => "Create Location", "code" => "CRLO"}
    ft24 = %{"name" => "Edit Location", "code" => "EDLO"}
    ft25 = %{"name" => "Delete Location", "code" => "DLLO"}
    ft26 = %{"name" => "List view of location", "code" => "LVLO"}
    ft27 = %{"name" => "View location", "code" => "VILO"}
    ft28 = %{"name" => "Import location", "code" => "IMLO"}
    ft29 = %{"name" => "Create parent-child relationship", "code" => "CRPC"}
    ft30 = %{"name" => "Edit parent-child relationship", "code" => "EDPC"}
    ft31 = %{"name" => "Delete parent-child relationship", "code" => "DLPC"}
    ft32 = %{"name" => "View parent-child relationship", "code" => "VIPC"}
    ft33 = %{"name" => "Import parent-child relationship", "code" => "IMPC"}

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

    md2 = %{"name" => "Asset management", "feature_ids" => [ft17c.id, ft18c.id, ft19c.id, ft20c.id, ft21c.id, ft22c.id, ft23c.id, ft24c.id,
                                                            ft25c.id, ft26c.id, ft27c.id, ft28c.id, ft29c.id, ft30c.id, ft31c.id, ft32c.id, ft33c.id]}
    {:ok, md2c} = Staff.create_module(md2, prefix)

    ft34 = %{"name" => "create Work order template", "code" => "CRWT"}
    ft35 = %{"name" => "Edit work order template", "code" => "EDWT"}
    ft36 = %{"name" => "Delete work order template", "code" => "DLWT"}
    ft37 = %{"name" => "List view work order template", "code" => "LVWT"}
    ft38 = %{"name" => "View work order template", "code" => "VIWT"}
    ft39 = %{"name" => "Create WO Schedule", "code" => "CRWS"}
    ft40 = %{"name" => "Edit WO Schedule", "code" => "EDWS"}
    ft41 = %{"name" => "Delete WO Schedule", "code" => "DLWS"}
    ft42 = %{"name" => "List view WO Schedule", "code" => "LVWS"}
    ft43 = %{"name" => "View WO Schedule", "code" => "VIWS"}
    ft44 = %{"name" => "Import WO Schedule", "code" => "IMWS"}
    ft45 = %{"name" => "Create work order", "code" => "CRWO"}
    ft46 = %{"name" => "Edit work order", "code" => "EDWO"}
    ft47 = %{"name" => "Delete work order", "code" => "DLWO"}
    ft48 = %{"name" => "List view work order", "code" => "LVWO"}
    ft49 = %{"name" => "Execute work order", "code" => "EXWO"}
    ft50 = %{"name" => "Reassign work order", "code" => "RAWO"}
    ft51 = %{"name" => "Reschedule work order", "code" => "RSWO"}
    ft52 = %{"name" => "View work order", "code" => "VIWO"}
    ft53 = %{"name" => "Create Tasks list", "code" => "CRTL"}
    ft54 = %{"name" => "Edit Tasks list", "code" => "EDTL"}
    ft55 = %{"name" => "Delete Tasks list", "code" => "DLTL"}
    ft56 = %{"name" => "List view tasks list", "code" => "LVTL"}
    ft57 = %{"name" => "View Tasks list", "code" => "VITL"}
    ft58 = %{"name" => "Import Task list", "code" => "IMTL"}
    ft59 = %{"name" => "Create Check list", "code" => "CRCL"}
    ft60 = %{"name" => "Edit Check list", "code" => "EDCL"}
    ft61 = %{"name" => "Delete Check list", "code" => "DLCL"}
    ft62 = %{"name" => "List view Check list", "code" => "LVCL"}
    ft63 = %{"name" => "View Check list", "code" => "VICL"}
    ft64 = %{"name" => "Import Check list", "code" => "IMCL"}
    ft65 = %{"name" => "Create work permit", "code" => "CRWP"}
    ft66 = %{"name" => "Edit work permit ", "code" => "EDWP"}
    ft67 = %{"name" => "Delete work permit", "code" => "DLWP"}
    ft68 = %{"name" => "List view work permit", "code" => "LVWP"}
    ft69 = %{"name" => "View work permit", "code" => "VIWP"}
    ft70 = %{"name" => "Import work permit", "code" => "IMWP"}
    ft71 = %{"name" => "Create LOTO", "code" => "CRLT"}
    ft72 = %{"name" => "Edit LOTO", "code" => "EDLT"}
    ft73 = %{"name" => "Delete LOTO", "code" => "DLLT"}
    ft74 = %{"name" => "List view LOTO", "code" => "LVLT"}
    ft75 = %{"name" => "View LOTO", "code" => "VILT"}
    ft76 = %{"name" => "Import LOTO", "code" => "IMLT"}

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

    md3 = %{"name" => "Workflow management", "feature_ids" => [ft34c.id, ft35c.id, ft36c.id, ft37c.id, ft38c.id, ft39c.id, ft40c.id, ft41c.id, ft42c.id, ft43c.id, ft44c.id, ft45c.id, ft46c.id,
                                                               ft47c.id, ft48c.id, ft49c.id, ft50c.id, ft51c.id, ft52c.id, ft53c.id, ft54c.id, ft55c.id, ft56c.id, ft57c.id, ft58c.id, ft59c.id,
                                                               ft60c.id, ft61c.id, ft62c.id, ft63c.id, ft64c.id, ft65c.id, ft66c.id, ft67c.id, ft68c.id, ft69c.id, ft70c.id, ft71c.id, ft72c.id,
                                                               ft73c.id, ft74c.id, ft75c.id, ft76c.id]}
    {:ok, md3c} = Staff.create_module(md3, prefix)

    ft77 = %{"name" => "Create Users", "code" => "CRUS"}
    ft78 = %{"name" => "Edit Users", "code" => "EDUS"}
    ft79 = %{"name" => "Delete Users", "code" => "DLUS"}
    ft80 = %{"name" => "List View Users", "code" => "LVUS"}
    ft81 = %{"name" => "View Users", "code" => "VIUS"}
    ft82 = %{"name" => "Create Users profile", "code" => "CRUP"}
    ft83 = %{"name" => "Edit Users profile", "code" => "EDUP"}
    ft84 = %{"name" => "Delete Users profile", "code" => "DLUP"}
    ft85 = %{"name" => "List View Users profile", "code" => "LVUP"}
    ft86 = %{"name" => "View Users profile", "code" => "VIUP"}
    ft87 = %{"name" => "Create Users roster", "code" => "CRUR"}
    ft88 = %{"name" => "Edit Users roster", "code" => "EDUR"}
    ft89 = %{"name" => "Delete Users roster", "code" => "DLUR"}
    ft90 = %{"name" => "List View Users roster", "code" => "LVUR"}
    ft91 = %{"name" => "View Users roster", "code" => "VIUR"}
    ft92 = %{"name" => "Create User group", "code" => "CRUG"}
    ft93 = %{"name" => "Edit User group", "code" => "EDUG"}
    ft94 = %{"name" => "Delete User group", "code" => "DLUG"}
    ft95 = %{"name" => "List View User group", "code" => "LVUG"}
    ft96 = %{"name" => "View User group", "code" => "VIUG"}

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

    md4 = %{"name" => "People management", "feature_ids" => [ft77c.id, ft78c.id, ft79c.id, ft80c.id, ft81c.id, ft82c.id, ft83c.id, ft84c.id, ft85c.id, ft86c.id,
                                                            ft87c.id, ft88c.id, ft89c.id, ft90c.id, ft91c.id, ft92c.id, ft93c.id, ft94c.id, ft95c.id, ft96c.id]}
    {:ok, md4c} = Staff.create_module(md4, prefix)

    ft97 = %{"name" => "Create part", "code" => "CRPA"}
    ft98 = %{"name" => "Edit part", "code" => "EDPA"}
    ft99 = %{"name" => "Delete part", "code" => "DLPA"}
    ft100 = %{"name" => "View part", "code" => "VIPA"}
    ft101 = %{"name" => "import part", "code" => "IMPA"}
    ft102 = %{"name" => "Create part details", "code" => "CRPD"}
    ft103 = %{"name" => "Edit part details", "code" => "EDPD"}
    ft104 = %{"name" => "Delete part details", "code" => "DLPD"}
    ft105 = %{"name" => "View part details", "code" => "VIPD"}
    ft106 = %{"name" => "import part details", "code" => "IMPD"}

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

    md5 = %{"name" => "Inventory management", "feature_ids" => [ft97c.id, ft98c.id, ft99c.id, ft100c.id, ft101c.id,
                                                            ft102c.id, ft103c.id, ft104c.id, ft105c.id, ft106c.id]}
    {:ok, md5c} = Staff.create_module(md5, prefix)

    ft107 = %{"name" => "Create tickets", "code" => "CRTI"}
    ft108 = %{"name" => "Edit tickets", "code" => "EDTI"}
    ft109 = %{"name" => "Delete tickets", "code" => "DLTI"}
    ft110 = %{"name" => "Assign tickets", "code" => "ASTI"}
    ft111 = %{"name" => "Reassign tickets", "code" => "RATI"}
    ft112 = %{"name" => "Close tickets", "code" => "CLTI"}
    ft113 = %{"name" => "Put tickets on Hold", "code" => "PTOH"}
    ft114 = %{"name" => "Edit ticket status", "code" => "EDTS"}
    ft115 = %{"name" => "Reopen ticket", "code" => "ROTI"}

    {:ok, ft107c} = Staff.create_feature(ft107, prefix)
    {:ok, ft108c} = Staff.create_feature(ft108, prefix)
    {:ok, ft109c} = Staff.create_feature(ft109, prefix)
    {:ok, ft110c} = Staff.create_feature(ft110, prefix)
    {:ok, ft111c} = Staff.create_feature(ft111, prefix)
    {:ok, ft112c} = Staff.create_feature(ft112, prefix)
    {:ok, ft113c} = Staff.create_feature(ft113, prefix)
    {:ok, ft114c} = Staff.create_feature(ft114, prefix)
    {:ok, ft115c} = Staff.create_feature(ft115, prefix)

    md6 = %{"name" => "Ticketing Management", "feature_ids" => [ft107c.id, ft108c.id, ft109c.id, ft110c.id, ft111c.id, ft112c.id, ft113c.id, ft114c.id, ft115c.id]}
    {:ok, md6c} = Staff.create_module(md6, prefix)

    ft116 = %{"name" => "Create alerts", "code" => "CRAL"}
    ft117 = %{"name" => "Edit alerts", "code" => "EDAL"}
    ft118 = %{"name" => "Delete alerts", "code" => "DLAL"}
    ft119 = %{"name" => "Acknowledge alerts", "code" => "AKAL"}
    ft120 = %{"name" => "Disable alerts", "code" => "DIAL"}
    ft121 = %{"name" => "import alerts", "code" => "IMAL"}
    ft122 = %{"name" => "View alerts", "code" => "VIAL"}
    ft123 = %{"name" => "Create notifications", "code" => "CRNT"}
    ft124 = %{"name" => "Edit notofications", "code" => "EDNT"}
    ft125 = %{"name" => "Delete notifications", "code" => "DLNT"}
    ft126 = %{"name" => "Disable notifications", "code" => "DINT"}
    ft127 = %{"name" => "import notifications", "code" => "IMNT"}
    ft128 = %{"name" => "Acknowledge notifications", "code" => "AKNT"}
    ft129 = %{"name" => "View notifications", "code" => "VINT"}

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

    md7 = %{"name" => "Alerts and Notifications", "feature_ids" => [ft116c.id, ft117c.id, ft118c.id, ft119c.id, ft120c.id, ft121c.id, ft122c.id,
                                                                    ft123c.id, ft124c.id, ft125c.id, ft126c.id, ft127c.id, ft128c.id, ft129c.id]}
    {:ok, md7c} = Staff.create_module(md7, prefix)

    ft130 = %{"name" => "Reports - Data download", "code" => "REDD"}
    ft131 = %{"name" => "Reports - Print", "code" => "REPR"}
    ft132 = %{"name" => "Dashboard & Reports - create", "code" => "DRCR"}
    ft133 = %{"name" => "Dashboard & Reports - edit", "code" => "DRED"}
    ft134 = %{"name" => "Dashboard & Reports - View", "code" => "DRVI"}

    {:ok, ft130c} = Staff.create_feature(ft130, prefix)
    {:ok, ft131c} = Staff.create_feature(ft131, prefix)
    {:ok, ft132c} = Staff.create_feature(ft132, prefix)
    {:ok, ft133c} = Staff.create_feature(ft133, prefix)
    {:ok, ft134c} = Staff.create_feature(ft134, prefix)

    md8 = %{"name" => "Reports and Dashboards", "feature_ids" => [ft130c.id, ft131c.id, ft132c.id, ft133c.id, ft134c.id]}
    {:ok, md8c} = Staff.create_module(md8, prefix)


    role1 = %{"name" => "Super Admin", "feature_ids" => [ft1c.id, ft2c.id, ft3c.id, ft4c.id, ft5c.id, ft6c.id, ft7c.id, ft8c.id, ft9c.id, ft10c.id, ft11c.id, ft12c.id, ft13c.id, ft14c.id, ft15c.id, ft16c.id, ft17c.id, ft18c.id, ft19c.id, ft20c.id, ft21c.id, ft22c.id, ft23c.id, ft24c.id, ft25c.id, ft26c.id, ft27c.id, ft28c.id, ft29c.id, ft30c.id,
                                                         ft31c.id, ft32c.id, ft33c.id, ft34c.id, ft35c.id, ft36c.id, ft37c.id, ft38c.id, ft39c.id, ft40c.id, ft41c.id, ft42c.id, ft43c.id, ft44c.id, ft45c.id, ft46c.id, ft47c.id, ft48c.id, ft49c.id, ft50c.id, ft51c.id, ft52c.id, ft53c.id, ft54c.id, ft55c.id, ft56c.id, ft57c.id, ft58c.id, ft59c.id, ft60c.id,
                                                         ft61c.id, ft62c.id, ft63c.id, ft64c.id, ft65c.id, ft66c.id, ft67c.id, ft68c.id, ft69c.id, ft70c.id, ft71c.id, ft72c.id, ft73c.id, ft74c.id, ft75c.id, ft76c.id, ft77c.id, ft78c.id, ft79c.id, ft80c.id, ft81c.id, ft82c.id, ft83c.id, ft84c.id, ft85c.id, ft86c.id, ft87c.id, ft88c.id, ft89c.id, ft90c.id,
                                                         ft91c.id, ft92c.id, ft93c.id, ft94c.id, ft95c.id, ft96c.id, ft97c.id, ft98c.id, ft99c.id, ft100c.id, ft101c.id, ft102c.id, ft103c.id, ft104c.id, ft105c.id, ft106c.id, ft107c.id, ft108c.id, ft109c.id, ft110c.id, ft111c.id, ft112c.id, ft113c.id, ft114c.id, ft115c.id, ft116c.id, ft117c.id, ft118c.id, ft119c.id, ft120c.id,
                                                         ft121c.id, ft122c.id, ft123c.id, ft124c.id, ft125c.id, ft126c.id, ft127c.id, ft128c.id, ft129c.id, ft130c.id, ft131c.id, ft132c.id, ft133c.id, ft134c.id]}

    role2 = %{"name" => "Admin", "feature_ids" => [ft4c.id, ft5c.id, ft7c.id, ft8c.id, ft9c.id, ft10c.id, ft11c.id, ft12c.id, ft13c.id, ft14c.id, ft15c.id, ft16c.id, ft17c.id, ft18c.id, ft19c.id, ft20c.id, ft21c.id, ft22c.id, ft23c.id, ft24c.id, ft25c.id, ft26c.id, ft27c.id, ft28c.id, ft29c.id, ft30c.id, ft31c.id, ft32c.id, ft33c.id, ft34c.id, ft35c.id,
                                                   ft36c.id, ft37c.id, ft38c.id, ft39c.id, ft40c.id, ft41c.id, ft42c.id, ft43c.id, ft44c.id, ft45c.id, ft46c.id, ft47c.id, ft48c.id, ft49c.id, ft50c.id, ft51c.id, ft52c.id, ft53c.id, ft54c.id, ft55c.id, ft56c.id, ft57c.id, ft58c.id, ft59c.id, ft60c.id, ft61c.id, ft62c.id, ft63c.id, ft64c.id, ft65c.id, ft66c.id,
                                                   ft67c.id, ft68c.id, ft69c.id, ft70c.id, ft71c.id, ft72c.id, ft73c.id, ft74c.id, ft75c.id, ft76c.id, ft77c.id, ft78c.id, ft79c.id, ft80c.id, ft81c.id, ft82c.id, ft83c.id, ft84c.id, ft85c.id, ft86c.id, ft87c.id, ft88c.id, ft89c.id, ft90c.id, ft91c.id, ft92c.id, ft93c.id, ft94c.id, ft95c.id, ft96c.id, ft97c.id,
                                                   ft98c.id, ft99c.id, ft100c.id, ft101c.id, ft102c.id, ft103c.id, ft104c.id, ft105c.id, ft106c.id, ft107c.id, ft108c.id, ft109c.id, ft110c.id, ft111c.id, ft112c.id, ft113c.id, ft114c.id, ft115c.id, ft116c.id, ft117c.id, ft118c.id, ft119c.id, ft120c.id, ft121c.id, ft122c.id, ft123c.id, ft124c.id, ft125c.id, ft126c.id,
                                                   ft127c.id, ft128c.id, ft129c.id, ft130c.id, ft131c.id, ft132c.id, ft133c.id, ft134c.id]}

    role3 = %{"name" => "Managers", "feature_ids" => [ft16c.id, ft17c.id, ft18c.id, ft20c.id, ft21c.id, ft23c.id, ft24c.id, ft26c.id, ft27c.id, ft29c.id, ft30c.id, ft32c.id, ft33c.id, ft35c.id, ft37c.id, ft38c.id, ft39c.id, ft40c.id, ft41c.id, ft42c.id, ft43c.id, ft44c.id, ft45c.id, ft46c.id, ft47c.id, ft48c.id, ft49c.id, ft50c.id,
                                                      ft51c.id, ft52c.id, ft53c.id, ft54c.id, ft55c.id, ft56c.id, ft57c.id, ft58c.id, ft59c.id, ft60c.id, ft62c.id, ft63c.id, ft64c.id, ft65c.id, ft66c.id, ft68c.id, ft69c.id, ft70c.id, ft71c.id, ft72c.id, ft74c.id, ft75c.id, ft76c.id, ft77c.id, ft78c.id, ft80c.id, ft81c.id, ft82c.id,
                                                      ft83c.id, ft85c.id, ft86c.id, ft87c.id, ft88c.id, ft90c.id, ft91c.id, ft92c.id, ft93c.id, ft95c.id, ft96c.id, ft97c.id, ft98c.id, ft99c.id, ft100c.id, ft101c.id, ft102c.id, ft103c.id, ft104c.id, ft105c.id, ft106c.id, ft107c.id, ft108c.id, ft109c.id, ft110c.id, ft111c.id, ft112c.id,
                                                      ft113c.id, ft114c.id, ft115c.id, ft116c.id, ft117c.id, ft119c.id, ft121c.id, ft122c.id, ft123c.id, ft124c.id, ft127c.id, ft128c.id, ft129c.id, ft130c.id, ft131c.id, ft132c.id, ft133c.id, ft134c.id]}

    role4 = %{"name" => "Supervisor", "feature_ids" => [ft16c.id, ft20c.id, ft21c.id, ft26c.id, ft27c.id, ft32c.id, ft37c.id, ft38c.id, ft39c.id, ft40c.id, ft42c.id, ft43c.id, ft44c.id, ft45c.id, ft46c.id, ft48c.id, ft49c.id, ft50c.id, ft51c.id, ft52c.id, ft53c.id, ft54c.id, ft56c.id, ft57c.id, ft58c.id, ft59c.id, ft60c.id, ft62c.id, ft63c.id, ft64c.id, ft65c.id,
                                                        ft66c.id, ft68c.id, ft69c.id, ft70c.id, ft72c.id, ft74c.id, ft75c.id, ft76c.id, ft80c.id, ft81c.id, ft85c.id, ft86c.id, ft88c.id, ft90c.id, ft91c.id, ft95c.id, ft96c.id, ft97c.id, ft98c.id, ft99c.id, ft100c.id, ft101c.id, ft102c.id, ft103c.id, ft104c.id, ft105c.id, ft106c.id, ft107c.id, ft108c.id, ft110c.id,
                                                        ft111c.id, ft112c.id, ft113c.id, ft114c.id, ft115c.id, ft116c.id, ft118c.id, ft119c.id, ft121c.id, ft122c.id, ft127c.id, ft128c.id, ft129c.id, ft130c.id, ft131c.id, ft134c.id]}

    role5 = %{"name" => "Technician", "feature_ids" => [ft16c.id, ft20c.id, ft21c.id, ft26c.id, ft27c.id, ft32c.id, ft37c.id, ft38c.id, ft42c.id, ft43c.id, ft48c.id, ft49c.id, ft50c.id, ft51c.id, ft52c.id, ft56c.id, ft57c.id, ft62c.id, ft63c.id, ft68c.id, ft69c.id, ft74c.id, ft75c.id, ft81c.id, ft86c.id, ft91c.id, ft96c.id, ft100c.id,
                                                        ft101c.id, ft105c.id, ft106c.id, ft107c.id, ft111c.id, ft112c.id, ft115c.id, ft116c.id, ft119c.id, ft121c.id, ft122c.id, ft128c.id, ft129c.id, ft134c.id]}

    role6 = %{"name" => "Others", "feature_ids" => [ft16c.id, ft20c.id, ft21c.id, ft26c.id, ft27c.id, ft32c.id, ft37c.id, ft38c.id, ft42c.id, ft43c.id, ft48c.id, ft52c.id, ft56c.id, ft57c.id, ft62c.id, ft63c.id, ft68c.id, ft69c.id, ft74c.id, ft75c.id, ft80c.id, ft81c.id, ft85c.id, ft86c.id, ft90c.id, ft91c.id, ft95c.id, ft96c.id, ft100c.id, ft105c.id, ft107c.id,
                                                    ft115c.id, ft116c.id, ft122c.id, ft129c.id, ft130c.id, ft131c.id, ft134c.id]}

    {:ok, role1c} = Staff.create_role(role1, prefix)
    {:ok, role2c} = Staff.create_role(role2, prefix)
    {:ok, role3c} = Staff.create_role(role3, prefix)
    {:ok, role4c} = Staff.create_role(role4, prefix)
    {:ok, role5c} = Staff.create_role(role5, prefix)
    {:ok, role6c} = Staff.create_role(role6, prefix)

    role2c
  end
end
