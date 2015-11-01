//
//  FirstViewController.swift
//  DSM-iOS
//
//  Created by Jannik Lorenz on 31.10.15.
//  Copyright © 2015 Jannik Lorenz. All rights reserved.
//

import Foundation
import XLForm


class SingleLineViewController: XLFormViewController {
    
    
    var line: Line?
    
    
    // MARK: Init
    
    convenience init(line: Line){
        self.init(nibName: nil, bundle: nil)
        
        self.line = line
    }
    
    
    
    
    // MARK: View Livestyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        line?.events.listenTo("setSession") { () -> () in
            self.initializeForm()
        }
        line?.events.listenTo("setConfig") { () -> () in
            self.initializeForm()
        }
        
        self.initializeForm()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
//        GAI.sharedInstance().trackScreenView("Acknowledgment")
        
        self.title = line?.title
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
    
    
    
    // MARK: Form Creation
    
    func initializeForm() {
        let form : XLFormDescriptor
        var section : XLFormSectionDescriptor
        var row : XLFormRowDescriptor
        
        form = XLFormDescriptor()
        
        section = XLFormSectionDescriptor() as XLFormSectionDescriptor
        form.addFormSection(section)
        
        
        
        // Disziplin
        row = XLFormRowDescriptor(tag: "disziplin", rowType: XLFormRowDescriptorTypeSelectorActionSheet, title: "Disziplin")
        row.selectorOptions = []
        var disziplinenList: [XLFormOptionsObject] = []
        if let groups = line?.config?["disziplinen"]["groups"].arrayValue {
            for singleGroup in groups {
                
                for disziplinID in singleGroup["disziplinen"].arrayValue {
                    
                    let disziplin = line?.config?["disziplinen"]["all"][disziplinID.stringValue]
                    
                    let option = XLFormOptionsObject(value: disziplinID.stringValue, displayText: disziplin?["title"].stringValue)
                    disziplinenList.append(option)
                    
                    
                    if (disziplinID.stringValue == line?.session?["disziplin"]["_id"].string) {
                        row.value = option
                    }
//
//                
                }
            }
        }
        row.selectorOptions = disziplinenList
        section.addFormRow(row)
        
        
        
        
        // Parts
        row = XLFormRowDescriptor(tag: "part", rowType: XLFormRowDescriptorTypeSelectorActionSheet, title: "Part")
        row.selectorOptions = []
        var partsList: [XLFormOptionsObject] = []
        if let parts = line?.session?["disziplin"]["parts"].dictionaryValue {
            for (key, part) in parts {
                let option = XLFormOptionsObject(value: key, displayText: part["title"].stringValue)
                partsList.append(option)
                if (key == line?.session?["type"].string) {
                    row.value = option
                }
            }
        }
        row.selectorOptions = partsList
        section.addFormRow(row)
        
        
        
        
        
        
        
        
        self.form = form
        self.tableView?.reloadData()
    }
    
    
    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        switch (formRow.tag){
        case "part"?:
            if let option = formRow.value as? XLFormOptionsObject {
                line?.setPart(option.valueData() as! String)
            }
        case "disziplin"?:
            if let option = formRow.value as? XLFormOptionsObject {
                line?.setDisziplin(option.valueData() as! String)
            }
        default:
            break
        }
    }
    
    
    
    
    
    
    
}
