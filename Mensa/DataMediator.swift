//
//  DataMediator.swift
//  Mensa
//
//  Created by Jordan Kay on 8/4/15.
//  Copyright © 2015 Tangible. All rights reserved.
//

import UIKit

typealias HostedViewControllerClass = HostedViewControllerType.Type
typealias DataMediatorDelegateType = DataMediatorDelegate.Type

struct DataMediator<Object, View: UIView, Cell: HostingCell, Delegate: DataMediatorDelegate where Object == Delegate.ObjectType, Object == Cell.ObjectType, View == Cell.ViewType, View == Delegate.ViewType, Cell == Delegate.HostingCellType> {
    private var metricsCells: [String: Cell] = [:]
    private unowned let delegate: Delegate

    var numberOfSections: Int {
        return backingSections.count
    }
    
    private var backingSections: [Section<Object>] = [] {
        didSet {
            for section in backingSections {
                for object in section {
                    let reuseIdentifier = reuseIdentifierForObject(object)
                    if metricsCells[reuseIdentifier] == nil {
                        if let metricsCell = createMetricsCellForObject(object) {
                            metricsCells[reuseIdentifier] = metricsCell
                        }
                    }
                }
            }
        }
    }
    
    init(delegate: Delegate) {
        self.delegate = delegate
    }
    
    mutating func reloadDataWithUpdate(update: Bool) {
        backingSections = delegate.sections
        delegate.didReloadWithUpdate(update)
    }
    
    func useViewController(viewController: HostedViewController<Object, View>, withObject object: Object) {
        viewController.updateView(viewController.hostedView, withObject: object)
        delegate.didUseViewController(viewController, withObject: object)
    }
    
    func canSelectObject(object: Object, forViewController viewController: HostedViewController<Object, View>) -> Bool {
        return viewController.canSelectObject(object)
    }
    
    func selectObject(object: Object, forViewController viewController: HostedViewController<Object, View>) {
        viewController.selectObject(object)
        delegate.didSelectObject(object)
    }
    
    func metricsCellForObject(object: Object) -> Cell? {
        let reuseIdentifier = reuseIdentifierForObject(object)
        return metricsCells[reuseIdentifier]
    }
    
    func backingObjectForRowAtIndexPath(indexPath: NSIndexPath) -> Object {
        return backingSections[indexPath.section][indexPath.row]
    }
    
    func numberOfObjectsInSection(section: Int) -> Int {
        return backingSections[section].count
    }
    
    func titleForSection(section: Int) -> String? {
        return backingSections[section].title
    }

    func summaryForSection(section: Int) -> String? {
        return backingSections[section].summary
    }
}

private extension DataMediator {
    func reuseIdentifierForObject(object: Object) -> String {
        let modelType = object.dynamicType
        let viewControllerClass: HostedViewController<Object, View>.Type = try! delegate.dynamicType.viewControllerClassForModelType(modelType)
        let variant = delegate.variantForObject(object)
        return viewControllerClass.reuseIdentifierForObject(object, variant: variant)
    }
    
    func createMetricsCellForObject(object: Object) -> Cell? {
        let modelType = object.dynamicType
        let viewControllerClass: HostedViewController<Object, View>.Type = try! delegate.dynamicType.viewControllerClassForModelType(modelType)

        var metricsCell: Cell!
        let variant = delegate.variantForObject(object)
        let reuseIdentifier = viewControllerClass.reuseIdentifierForObject(object, variant: variant)
        let cellClass = delegate.cellClass.subclassWithViewControllerClass(viewControllerClass, modelType: object.dynamicType, variant: variant)
        delegate.willUseCellClass(cellClass, forReuseIdentifier: reuseIdentifier)
        if let cellClass = cellClass as? UITableViewCell.Type {
            metricsCell = cellClass.init() as? Cell
        } else if let cellClass = cellClass as? UICollectionViewCell.Type {
            metricsCell = cellClass.init() as? Cell
        }
        
        delegate.willLoadHostedViewController(metricsCell.hostedViewController)
        loadHostedViewForObject(object, inCell: metricsCell)
        delegate.willUseMetricsCell(metricsCell, forObject: object)
        return metricsCell
    }
}

protocol DataMediatorDelegate: class {
    typealias ObjectType
    typealias ViewType: UIView
    typealias HostingCellType: HostingCell

    var sections: [Section<ObjectType>] { get }
    var cellClass: HostingCellType.Type { get }

    func didReloadWithUpdate(update: Bool)
    func willUseCellClass(cellClass: CellClass, forReuseIdentifier reuseIdentifier: String)
    func variantForObject(object: ObjectType) -> Int
    func willUseMetricsCell(metricsCell: HostingCellType, forObject: ObjectType)
    func didSelectObject(object: ObjectType)
    func willLoadHostedViewController(viewController: HostedViewController<ObjectType, ViewType>)
    func didUseViewController(viewController: HostedViewController<ObjectType, ViewType>, withObject object: ObjectType)
}

public protocol DataMediatedViewController {
    var dataView: UIScrollView { get }
}
