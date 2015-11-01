//
//  SecondViewController.swift
//  DSM-iOS
//
//  Created by Jannik Lorenz on 31.10.15.
//  Copyright © 2015 Jannik Lorenz. All rights reserved.
//

import UIKit
import XLForm

class LinesViewController: XLFormViewController {
    
    
    // MARK: Init
    
    convenience init(){
        self.init(nibName: nil, bundle: nil)
        
        self.title = "Linien"
    }

    
    
    
    
    // MARK: View Livestyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        initializeForm()
    }

    
    
    
    // MARK: Form Creation
    
    func initializeForm() {
        let form : XLFormDescriptor
        var section : XLFormSectionDescriptor
        var row : XLFormRowDescriptor
        
        form = XLFormDescriptor()
        
        section = XLFormSectionDescriptor() as XLFormSectionDescriptor
        form.addFormSection(section)
        
        
        
        for line in lines {
            row = XLFormRowDescriptor(tag: line.id, rowType: XLFormRowDescriptorTypeSelectorPush, title: line.title)
            row.value = ""
            row.action.formBlock = { (descriptor: XLFormRowDescriptor!) -> Void in
                self.tableView.selectRowAtIndexPath(nil, animated: true, scrollPosition: .None)
            }
            section.addFormRow(row)
        }
        
        
        
        
        self.form = form
        self.tableView?.reloadData()
    }
    
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        super.tableView(tableView, didSelectRowAtIndexPath: indexPath)
        
        switch (indexPath.section, indexPath.row) {
        case (0, 0...lines.count):
            let singleVC = SingleLineViewController(line: lines[indexPath.row])
            self.navigationController?.pushViewController(singleVC, animated: true)
            
        default:
            break
        }
    }

}

