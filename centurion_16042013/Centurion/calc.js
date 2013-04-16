function doAnalysis(jsonData) {
    jsonData = JSON.parse(jsonData);
    
    var reduced = "";
    if (jsonData.centurion_fail_rate > 0 && (jsonData.centurion_fail_rate < jsonData.current_fail_rate)) {
        reduced = "REDUCED";
    }
    // Convert fail rate % to float
    jsonData.current_fail_rate = (jsonData.current_fail_rate/100);
    jsonData.centurion_fail_rate = (jsonData.centurion_fail_rate/100);
    
    //Constants
    var cost_per_hai = 29500;
    var cost_per_malpractise_claim = 150000;
    var cost_per_hospital_stay = 12971;
    
    var cenutrion_patients_per_month = parseFloat((jsonData.patients_per_month * (jsonData.percent_piv/100))).toFixed(0);
    console.log(cenutrion_patients_per_month);
    //Value Analysis
    var estimated_cost_due_to_unscheduled_restarts = jsonData.current_fail_rate * cenutrion_patients_per_month * (jsonData.material_cost + jsonData.time_to_restart/60 * jsonData.labor_cost) * 12;
    estimated_cost_due_to_unscheduled_restarts = estimated_cost_due_to_unscheduled_restarts.toFixed(0);
    var adjusted_costs = jsonData.centurion_fail_rate * cenutrion_patients_per_month * (jsonData.material_cost + jsonData.time_to_restart/60 * jsonData.labor_cost) * 12;
    if (isNumber(adjusted_costs)) {
        adjusted_costs = adjusted_costs.toFixed(0);
    } else {
        adjusted_costs = 0;
    }
    
    var potencial_savings = estimated_cost_due_to_unscheduled_restarts - adjusted_costs;
    if (isNumber(potencial_savings)) {
        potencial_savings = potencial_savings.toFixed(0);
    } else {
        potencial_savings = 0;
    }
    
    
    //**************Current Costs ******************//
    //////////////////
    //Direct Costs  //
    //////////////////
    var unscheduled_restarts = cenutrion_patients_per_month * jsonData.current_fail_rate * 12;
    if (isNumber(unscheduled_restarts)) {
        unscheduled_restarts = unscheduled_restarts.toFixed(0);
    } else {
        unscheduled_restarts = 0;
    }
    var clinician_time  =  jsonData.time_to_restart * cenutrion_patients_per_month * jsonData.current_fail_rate * 12 / 60;
    if (isNumber(clinician_time)) {
        clinician_time = clinician_time.toFixed(0);
    } else {
        clinician_time = 0;
    }
    var clinician_salary = jsonData.time_to_restart * cenutrion_patients_per_month * (jsonData.current_fail_rate * 12 / 60) * jsonData.labor_cost;
    if (isNumber(clinician_salary)) {
        clinician_salary = clinician_salary.toFixed(0);
    } else {
        clinician_salary = 0;
    }
    var materials_wasted = cenutrion_patients_per_month * jsonData.current_fail_rate * jsonData.material_cost*12;
    if (isNumber(materials_wasted)) {
        materials_wasted = materials_wasted.toFixed(0);
    } else {
        materials_wasted = 0;
    }
    var budget_reallocation = jsonData.material_cost;
    if (isNumber(budget_reallocation)) {
        budget_reallocation = budget_reallocation.toFixed(2);
    } else {
        budget_reallocation = 0;
    }
    
    //////////////////////////
    //Dissatisfaction Costs //
    //////////////////////////
    var resticks = unscheduled_restarts * jsonData.restart_stick;
    if (isNumber(resticks)) {
        resticks = resticks.toFixed(0);
    } else {
        resticks = 0;
    }
    var patient_discomfort = jsonData.current_fail_rate*100;
    if (isNumber(patient_discomfort)) {
        patient_discomfort = patient_discomfort.toFixed(0);
    } else {
        patient_discomfort = 0;
    }
    
    ////////////////////
    //Financial Risks //
    ////////////////////
    var infection_risks         = cost_per_hospital_stay * jsonData.piv_complications * 12;
    if (isNumber(infection_risks)) {
        infection_risks = infection_risks.toFixed(0);
    } else {
        infection_risks = 0;
    }
    var phlebitis_risk          = jsonData.current_fail_rate*100;
    if (isNumber(phlebitis_risk)) {
        phlebitis_risk = phlebitis_risk.toFixed(0);
    } else {
        phlebitis_risk = 0;
    }
    var infiltration_risk       = jsonData.current_fail_rate*100;
    if (isNumber(infiltration_risk)) {
        infiltration_risk = infiltration_risk.toFixed(0);
    } else {
        infiltration_risk = 0;
    }
    var extravasation_risk      = jsonData.current_fail_rate*100;
    if (isNumber(extravasation_risk)) {
        extravasation_risk = extravasation_risk.toFixed(0);
    } else {
        extravasation_risk = 0;
    }
    var medical_liability_risks = jsonData.current_fail_rate*100;
    if (isNumber(medical_liability_risks)) {
        medical_liability_risks = medical_liability_risks.toFixed(0);
    } else {
        medical_liability_risks = 0;
    }
    
    //**************Adjusted Costs ******************//
    //////////////////
    //Direct Costs  //
    //////////////////
    var centurion_unscheduled_restarts = cenutrion_patients_per_month * jsonData.centurion_fail_rate * 12;
    
    //centurion_unscheduled_restarts = centurion_unscheduled_restarts.toFixed(0);
    
    if (isNumber(centurion_unscheduled_restarts)) {
        centurion_unscheduled_restarts = centurion_unscheduled_restarts.toFixed(0);
    } else {
        centurion_unscheduled_restarts = 0;
    }
    var centurion_clinician_time  =  jsonData.time_to_restart * cenutrion_patients_per_month * jsonData.centurion_fail_rate * 12 / 60;
    if (isNumber(centurion_clinician_time)) {
        centurion_clinician_time = centurion_clinician_time.toFixed(0);
    } else {
        centurion_clinician_time = 0;
    }
    var centurion_clinician_salary = jsonData.time_to_restart * cenutrion_patients_per_month * (jsonData.centurion_fail_rate * 12 / 60) * jsonData.labor_cost;
    if (isNumber(centurion_clinician_salary)) {
        centurion_clinician_salary = centurion_clinician_salary.toFixed(0);
    } else {
        centurion_clinician_salary = 0;
    }
    var centurion_materials_wasted = cenutrion_patients_per_month * jsonData.centurion_fail_rate * jsonData.material_cost *12;
    if (isNumber(centurion_materials_wasted)) {
        centurion_materials_wasted = centurion_materials_wasted.toFixed(0);
    } else {
        centurion_materials_wasted = 0;
    }
    var centurion_budget_reallocation = cenutrion_patients_per_month*jsonData.material_cost/(cenutrion_patients_per_month*(1-(jsonData.current_fail_rate-jsonData.centurion_fail_rate)));
    if (isNumber(centurion_budget_reallocation)) {
        centurion_budget_reallocation = centurion_budget_reallocation.toFixed(2);
    } else {
        centurion_budget_reallocation = 0;
    }
    
    //////////////////////////
    //Dissatisfaction Costs //
    //////////////////////////
    var centurion_resticks = centurion_unscheduled_restarts * jsonData.restart_stick;
    if (isNumber(centurion_resticks)) {
        centurion_resticks = centurion_resticks.toFixed(0);
    } else {
        centurion_resticks = 0;
    }
    var centurion_patient_discomfort = jsonData.centurion_fail_rate*100;
    if (isNumber(centurion_patient_discomfort)) {
        centurion_patient_discomfort = centurion_patient_discomfort.toFixed(0);
    } else {
        centurion_patient_discomfort = 0;
    }
    console.log("187"+"    "+centurion_unscheduled_restarts);
    ////////////////////
    //Financial Risks //
    ////////////////////
    var centurion_infection_risks         = infection_risks * (1-(jsonData.current_fail_rate-jsonData.centurion_fail_rate));
    if (isNumber(centurion_infection_risks)) {
        centurion_infection_risks = centurion_infection_risks.toFixed(0);
    } else {
        centurion_infection_risks = 0;
    }
    var centurion_phlebitis_risk          = jsonData.centurion_fail_rate*100;
    if (isNumber(centurion_phlebitis_risk)) {
        centurion_phlebitis_risk = centurion_phlebitis_risk.toFixed(0);
    } else {
        centurion_phlebitis_risk = 0;
    }
    var centurion_infiltration_risk       = jsonData.centurion_fail_rate*100;
    if (isNumber(centurion_infiltration_risk)) {
        centurion_infiltration_risk = centurion_infiltration_risk.toFixed(0);
    } else {
        centurion_infiltration_risk = 0;
    }
    var centurion_extravasation_risk      = jsonData.centurion_fail_rate*100;
    if (isNumber(centurion_extravasation_risk)) {
        centurion_extravasation_risk = centurion_extravasation_risk.toFixed(0);
    } else {
        centurion_extravasation_risk = 0;
    }
    var centurion_medical_liability_risks = jsonData.centurion_fail_rate*100;
    if (isNumber(centurion_medical_liability_risks)) {
        centurion_medical_liability_risks = centurion_medical_liability_risks.toFixed(0);
    } else {
        centurion_medical_liability_risks = 0;
    }
    
    
    //**************Potential Savings ******************//
    //////////////////
    //Direct Costs  //
    //////////////////
    var savings_unscheduled_restarts = unscheduled_restarts - centurion_unscheduled_restarts;
    if (isNumber(savings_unscheduled_restarts)) {
        savings_unscheduled_restarts = savings_unscheduled_restarts.toFixed(0);
    } else {
        savings_unscheduled_restarts = 0;
    }
    
    var savings_clinician_time  =  clinician_time - centurion_clinician_time;
    if (isNumber(savings_clinician_time)) {
        savings_clinician_time = savings_clinician_time.toFixed(0);
    } else {
        savings_clinician_time = 0;
    }
    
    var savings_clinician_salary = clinician_salary - centurion_clinician_salary;
    if (isNumber(savings_clinician_salary)) {
        savings_clinician_salary = savings_clinician_salary.toFixed(0);
    } else {
        savings_clinician_salary = 0;
    }
    
    var savings_materials_wasted = materials_wasted - centurion_materials_wasted;
    if (isNumber(savings_materials_wasted)) {
        savings_materials_wasted = savings_materials_wasted.toFixed(0);
    } else {
        savings_materials_wasted = 0;
    }
    
    var savings_budget_reallocation = budget_reallocation - centurion_budget_reallocation;
    if (isNumber(savings_budget_reallocation)) {
        savings_budget_reallocation = savings_budget_reallocation.toFixed(2);
    } else {
        savings_budget_reallocation = 0;
    }
    
    //////////////////////////
    //Dissatisfaction Costs //
    //////////////////////////
    var savings_resticks = resticks - centurion_resticks;
    if (isNumber(savings_resticks)) {
        savings_resticks = savings_resticks.toFixed(0);
    } else {
        savings_resticks = 0;
    }
    
    var savings_patient_discomfort = patient_discomfort - centurion_patient_discomfort;
    if (isNumber(savings_patient_discomfort)) {
        savings_patient_discomfort = savings_patient_discomfort.toFixed(0);
    } else {
        savings_patient_discomfort = 0;
    }
    
    ////////////////////
    //Financial Risks //
    ////////////////////
    var savings_infection_risks         = infection_risks - centurion_infection_risks;
    if (isNumber(savings_infection_risks)) {
        savings_infection_risks = savings_infection_risks.toFixed(0);
    } else {
        savings_infection_risks = 0;
    }
    
    var savings_phlebitis_risk          = phlebitis_risk - centurion_phlebitis_risk;
    if (isNumber(savings_phlebitis_risk)) {
        savings_phlebitis_risk = savings_phlebitis_risk.toFixed(0);
    } else {
        savings_phlebitis_risk = 0;
    }
    
    var savings_infiltration_risk       = infiltration_risk - centurion_infiltration_risk;
    if (isNumber(savings_infiltration_risk)) {
        savings_infiltration_risk = savings_infiltration_risk.toFixed(0);
    } else {
        savings_infiltration_risk = 0;
    }
    
    var savings_extravasation_risk      = extravasation_risk - centurion_extravasation_risk;
    if (isNumber(savings_extravasation_risk)) {
        savings_extravasation_risk = savings_extravasation_risk.toFixed(0);
    } else {
        savings_extravasation_risk = 0;
    }
    
    var savings_medical_liability_risks = medical_liability_risks - centurion_medical_liability_risks;
    if (isNumber(savings_medical_liability_risks)) {
        savings_medical_liability_risks = savings_medical_liability_risks.toFixed(0);
    } else {
        savings_medical_liability_risks = 0;
    }
    
    
    var returnData = {
        "template_id" : 1,
        //Requires $, comma, fix to 2 decimals
        "cost_savings_placeholder_1":{"label":"ESTIMATED COSTS DUE TO UNSCHEDULED RESTARTS","value": "$" + numberWithCommas(estimated_cost_due_to_unscheduled_restarts) + " /yr.", "sub_value":  "$" + numberWithCommas((estimated_cost_due_to_unscheduled_restarts/12).toFixed(0)) + " /mo."},
        "cost_savings_placeholder_2":{"label":"ADJUSTED COSTS","value":"$" + numberWithCommas(adjusted_costs) + " /yr.", "sub_value" : "$" + numberWithCommas((adjusted_costs/12).toFixed(0)) + " /mo."},
        "cost_savings_placeholder_3":{"label":"POTENTIAL SAVINGS","value":"$" + numberWithCommas(potencial_savings) + " /yr.", "sub_value" :  "$" + numberWithCommas((potencial_savings/12).toFixed(0)) + " /mo."},
        "analysis_table_columns" : ["CURRENT", "POTENTIAL", "SAVINGS"],
        "analysis_table":[{"section_title": "Direct Costs",
                          "section_elements" :    [
                                                   {"image_name":"unscheduled_restart.png", "title" : "Unscheduled Restarts", "first_value" : numberWithCommas(unscheduled_restarts)+" /yr.", "first_sub_value" : numberWithCommas((unscheduled_restarts/12).toFixed(0))+" /mo.", "second_value" : numberWithCommas(centurion_unscheduled_restarts)+" /yr.", "second_sub_value" : numberWithCommas((centurion_unscheduled_restarts/12).toFixed(0))+" /mo.", "third_value" : numberWithCommas(savings_unscheduled_restarts)+" /yr.", "third_sub_value" : numberWithCommas((savings_unscheduled_restarts/12).toFixed(0))+" /mo."},
                                                   {"image_name":"maximum_material_cost.png", "title" : "Materials", "first_value" : "$"+ numberWithCommas(budget_reallocation)+" /ea.", "second_value" : "$"+ numberWithCommas(centurion_budget_reallocation)+" /ea.", "third_value" : "With your current budget, you can now spend up to $"+numberWithCommas(centurion_budget_reallocation)+" per PIV start"},
                                                   
                                                   {"image_name":"clinician_time.png", "title" : "Clinician Time Wasted", "first_value" : numberWithCommas(clinician_time) +" /yr.", "first_sub_value" : numberWithCommas((clinician_time/12).toFixed(0))+" /mo.", "second_value" : numberWithCommas(centurion_clinician_time)+" /yr.", "second_sub_value" : numberWithCommas((centurion_clinician_time/12).toFixed(0))+" /mo.", "third_value" : numberWithCommas(savings_clinician_time)+" /yr.", "third_sub_value" : numberWithCommas((savings_clinician_time/12).toFixed(0))+" /mo."},
                                                   {"image_name":"clinician_salary.png", "title" : "Labor Wasted", "first_value" : "$"+ numberWithCommas(clinician_salary)+" /yr.", "first_sub_value" : "$"+ numberWithCommas((clinician_salary/12).toFixed(0))+" /mo.", "second_value" : "$"+numberWithCommas((centurion_clinician_salary))+" /yr.", "second_sub_value" : "$"+numberWithCommas((centurion_clinician_salary/12).toFixed(0))+" /mo.", "third_value" : "$"+numberWithCommas((savings_clinician_salary))+" /yr.", "third_sub_value" : "$"+numberWithCommas((savings_clinician_salary/12).toFixed(0))+" /mo."},
                                                   {"image_name":"materials_wasted.png", "title" : "Materials Wasted", "first_value" : "$"+ numberWithCommas(materials_wasted)+" /yr.", "first_sub_value" : "$" + numberWithCommas((materials_wasted/12).toFixed(0))+" /mo.", "second_value" : "$"+numberWithCommas(centurion_materials_wasted)+" /yr.", "second_sub_value" : "$"+numberWithCommas((centurion_materials_wasted/12).toFixed(0))+" /mo.", "third_value" : "$"+numberWithCommas(savings_materials_wasted)+" /yr.", "third_sub_value" : "$"+numberWithCommas((savings_materials_wasted/12).toFixed(0))+" /mo."}
                                                   ]},
                          {"section_title": "Dissatisfaction Costs",
                          "section_elements": [
                                               {"image_name":"resticks.png", "title" : "Resticks", "first_value" : numberWithCommas(resticks)+" /yr.", "first_sub_value" : numberWithCommas((resticks/12).toFixed(0))+" /mo.", "second_value" : numberWithCommas(centurion_resticks)+" /yr.", "second_sub_value" : numberWithCommas((centurion_resticks/12).toFixed(0))+" /mo.", "third_value" : numberWithCommas(savings_resticks)+" /yr.", "third_sub_value" : numberWithCommas((savings_resticks/12).toFixed(0))+" /mo."},
                                               {"image_name":"patient_discomfort.png", "title" : "Patient Discomfort", "first_value" : "YES", "second_value" : "", "third_value" : reduced}
                                               ]},
                          {"section_title" : "Financial Risks",
                          "section_elements" : [
                                                {"image_name":"phlebitis_risk.png", "title" : "Phlebitis Risk", "first_value" : "YES", "second_value" : "", "third_value" : reduced},
                                                {"image_name":"infiltration_risk.png", "title" : "Infiltration Risk", "first_value" : "YES", "second_value" : "", "third_value" : reduced},
                                                {"image_name":"extravasation_risk.png", "title" : "Extravasation Risk", "first_value" : "YES", "second_value" : "", "third_value" : reduced},
                                                
                                                {"image_name":"dislodgement_risk.png", "title" : "Dislodgement Risk", "first_value" : "YES", "second_value" : "", "third_value" : reduced},
                                                {"image_name":"medical_liability_risk.png", "title" : "Medical Liability Risk", "first_value" : "YES", "second_value" : "", "third_value" : reduced}
                                                ]}
                          ]
    };
    return JSON.stringify(returnData);
}


function isNumber(n) {
    return !isNaN(parseFloat(n)) && isFinite(n);
}


function numberWithCommas(x) {
    return x.toString().replace(/\B(?=(\d{3})+(?!\d))/g, ",");
}