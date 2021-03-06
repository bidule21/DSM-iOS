//
//  FirstViewController.swift
//  DSM-iOS
//
//  Created by Jannik Lorenz on 31.10.15.
//  Copyright © 2015 Jannik Lorenz. All rights reserved.
//

import Foundation
import XLForm
import SwiftyJSON


class SingleLineViewController: XLFormViewController {
    
    
    var line: Line?
    
    var updateing = false
    
    
    // MARK: Init
    
    convenience init(line: Line){
        self.init(nibName: nil, bundle: nil)
        
        self.line = line
        
        
        line.events.listenTo("setSession") { () -> () in
            self.updateForm()
        }
        line.events.listenTo("setConfig") { () -> () in
            self.updateForm()
        }
        
        line.events.listenTo("disconnect", action: { () -> () in
            self.navigationController?.popViewControllerAnimated(true)
        })
        line.events.listenTo("error", action: { () -> () in
            self.navigationController?.popViewControllerAnimated(true)
        })
        
        
        self.initializeForm()
    }
    
    
    
    
    // MARK: View Livestyle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let session = line?.session {
//            let f = Test_View(frame: CGRectMake(0, 0, view.frame.width, 500), session: session)
//            view.addSubview(f)
//        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = line?.title
        
        self.updateForm()
    }
    
    
    
    
    
    // MARK: Form Creation
    
    func initializeForm() {
        let form : XLFormDescriptor
        var section : XLFormSectionDescriptor
        var row : XLFormRowDescriptor
        
        form = XLFormDescriptor()
        
        
        
        
        section = XLFormSectionDescriptor() as XLFormSectionDescriptor
        form.addFormSection(section)
        section.title = "Modus"
        
        // Disziplin
        row = XLFormRowDescriptor(tag: "disziplin", rowType: XLFormRowDescriptorTypeSelectorActionSheet, title: "Disziplin")
        section.addFormRow(row)
        
        
        // Parts
        row = XLFormRowDescriptor(tag: "part", rowType: XLFormRowDescriptorTypeSelectorActionSheet, title: "Part")
        section.addFormRow(row)
        
        
        
        
        
        section = XLFormSectionDescriptor() as XLFormSectionDescriptor
        form.addFormSection(section)
        section.title = "Nachricht"
        
        // Nachricht
        row = XLFormRowDescriptor(tag: "message", rowType: XLFormRowDescriptorTypeSelectorActionSheet, title: "Nachricht")
        row.selectorOptions = [
            XLFormOptionsObject(value: "sicherheit", displayText: "Sicherheit"),
            XLFormOptionsObject(value: "pause", displayText: "Pause"),
        ]
        section.addFormRow(row)
        
        
        // Nachricht ausblenden
        row = XLFormRowDescriptor(tag: "hideMessage", rowType: XLFormRowDescriptorTypeButton, title: "Nachricht ausblenden")
        row.action.formBlock = { form in
            self.tableView.selectRowAtIndexPath(nil, animated: true, scrollPosition: .None)
            self.line?.hideMessage()
        }
        section.addFormRow(row)
        
        
        
        
        self.form = form
        self.tableView?.reloadData()
    }
    
    
    func updateForm(){
        self.updateing = true
        
        // Disziplin
        var row = form.formRowWithTag("disziplin")
        var disziplinenList: [XLFormOptionsObject] = []
        if let groups = line?.config?["disziplinen"]["groups"].arrayValue {
            for singleGroup in groups {
                for disziplinID in singleGroup["disziplinen"].arrayValue {
                    
                    let disziplin = line?.config?["disziplinen"]["all"][disziplinID.stringValue]
                    
                    let option = XLFormOptionsObject(value: disziplinID.stringValue, displayText: disziplin?["title"].stringValue)
                    disziplinenList.append(option)
                    
                    if (disziplinID.stringValue == line?.session?["disziplin"]["_id"].string) {
                        row?.value = option
                    }
                }
            }
        }
        row?.selectorOptions = disziplinenList
        
        
        
        
        
        // Parts
        row = form.formRowWithTag("part")
        var partsList: [XLFormOptionsObject] = []
        if let parts = line?.session?["disziplin"]["parts"].dictionaryValue {
            for (key, part) in parts {
                let option = XLFormOptionsObject(value: key, displayText: part["title"].stringValue)
                partsList.append(option)
                if (key == line?.session?["type"].string) {
                    row?.value = option
                }
            }
        }
        row?.selectorOptions = partsList
        
        
        
        
        self.tableView?.reloadData()
        
        self.updateing = false
    }
    
    
    override func formRowDescriptorValueHasChanged(formRow: XLFormRowDescriptor!, oldValue: AnyObject!, newValue: AnyObject!) {
        if updateing {
            return
        }
        
        switch (formRow.tag){
        case "part"?:
            if let option = formRow.value as? XLFormOptionsObject {
                line?.setPart(option.valueData() as! String)
            }
        case "disziplin"?:
            if let option = formRow.value as? XLFormOptionsObject {
                line?.setDisziplin(option.valueData() as! String)
            }
        case "message"?:
            if let option = formRow.value?.valueData() as? String {
                switch (option){
                case "sicherheit":
                    line?.showMessage("Sicherheit", type: Line.DSCAPIMethodMessage.danger)
                case "pause":
                    line?.showMessage("Pause", type: Line.DSCAPIMethodMessage.black)
                default:
                    break
                }
                formRow.value = nil
            }
        default:
            break
        }
    }
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    
    class Test_View: UIView {
        
        var session: JSON?
        
//        override init(frame: CGRect) {
//            super.init(frame: frame)
//        }
//        
//        required init?(coder aDecoder: NSCoder) {
//            super.init(coder: aDecoder)
//        }
        
        convenience init(frame: CGRect, session: JSON){
            self.init(frame: frame)
            self.session = session
        }
        
        override func drawRect(rect: CGRect) {
            let scheibe = session?["disziplin"]["scheibe"]
            
            /*
            var lastRing = scheibe.ringe[scheibe.ringe.length-1]
            
            for (var i = scheibe.ringe.length-1; i >= 0; i--){
            var ring = scheibe.ringe[i]
            
            context.globalAlpha = 1.0
            context.fillStyle = ring.color;
            context.beginPath();
            context.arc(lastRing.width/2*zoom.scale+zoom.offset.x, lastRing.width/2*zoom.scale+zoom.offset.y, ring.width/2*zoom.scale, 0, 2*Math.PI);
            context.closePath();
            
            context.fill();
            context.strokeStyle = ring.textColor
            context.lineWidth = 4;
            context.stroke();
            context.fillStyle = "black";
            
            if (ring.text == true){
            context.font = "bold "+(scheibe.text.size*zoom.scale)+"px verdana, sans-serif";
            context.fillStyle = ring.textColor
            context.fillText(ring.value, (lastRing.width/2 - ring.width/2 + scheibe.text.left)*zoom.scale+zoom.offset.x, (lastRing.width/2+scheibe.text.width)*zoom.scale+zoom.offset.y);
            context.fillText(ring.value, (lastRing.width/2 + ring.width/2 + scheibe.text.right)*zoom.scale+zoom.offset.x, (lastRing.width/2+scheibe.text.width)*zoom.scale+zoom.offset.y);
            context.fillText(ring.value, (lastRing.width/2-scheibe.text.width)*zoom.scale+zoom.offset.x, (lastRing.width/2 + ring.width/2 + scheibe.text.down)*zoom.scale+zoom.offset.y);
            context.fillText(ring.value, (lastRing.width/2-scheibe.text.width)*zoom.scale+zoom.offset.x, (lastRing.width/2 - ring.width/2 + scheibe.text.up)*zoom.scale+zoom.offset.y);
            }
            }
            */
            
            if let ringe = scheibe?["ringe"].arrayValue {
                let lastRing = ringe.last
                
                for ring in ringe {
                    print(ring)
                    
//                    let radius = ring["width"].intValue/ 2*
                    
                    var path = UIBezierPath(ovalInRect: CGRect(x: 0, y: 0, width: 300, height: 300))
                    UIColor.greenColor().setFill()
                    path.fill()
                    
                }
            }
            
            
            
            
            
//            let h = rect.height
//            let w = rect.width
//            var color:UIColor = UIColor.yellowColor()
//            
//            var drect = CGRect(x: (w * 0.25),y: (h * 0.25),width: (w * 0.5),height: (h * 0.5))
//            var bpath:UIBezierPath = UIBezierPath(rect: drect)
            
//            color.set()
//            bpath.stroke()
            
            
        }
        
    }
    
    
    
    
    
    
    
    
}
