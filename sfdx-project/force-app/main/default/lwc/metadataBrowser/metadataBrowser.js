import { LightningElement, track, wire } from 'lwc';
import retrieveDescribeMetadata from '@salesforce/apex/MetadataBrowserLwcController.retrieveDescribeMetadata';
import retrieveListMetadata from '@salesforce/apex/MetadataBrowserLwcController.retrieveListMetadata';

export default class MetadataBrowser extends LightningElement {
    descMetaResult;
    gridColumns = [
        {
            type: 'text',
            fieldName: 'metadataType',
            label: 'Metadata Type',
        }
    ];
    @track gridData;
    @track expandedRows = [];
    
    get isMetadataListLoaded() {
        return !(!this.gridColumns) && !(!this.gridData);
    }
    
    @wire(retrieveDescribeMetadata, {})
    wiredDescribeMetadata({ error, data }) {
        if (data) {
            this.descMetaResult = JSON.parse(data);
            console.log(`this.descMetaResult: ${JSON.stringify(this.descMetaResult, null, 4)}`);
            this.populateGridData();
        } else if (error) {
            console.error(error);
        }
    }
    
    populateGridData() {
        const dataArray = [];
        console.log('Populating dataArray');
        this.descMetaResult.metadataObjects.forEach(metadataObj => {
            dataArray.push({
                metadataType: metadataObj.xmlName,
                hasCalledApi: false,
                inFolder: metadataObj.inFolder,
                _children: []
            });
        });
        dataArray.sort((itemA, itemB) => {
            return itemA.metadataType.localeCompare(itemB.metadataType)
        });
        this.gridData = dataArray;
    }
    
    // connectedCallback() {
    //     console.log('This one has children!');
    // }
    
    renderedCallback() {
        // console.log(`this.isMetadataListLoaded: ${this.isMetadataListLoaded}`);
    }
    
    handleToggle(event) {
        console.log(`event.detail: ${JSON.stringify(event.detail, null, 4)}`);
        const mdType = event.detail.name;
        const treeGrid = this.template.querySelector('lightning-tree-grid');
        const currentExpandedRows = treeGrid.getCurrentExpandedRows();
        console.log(`currentExpandedRows: ${JSON.stringify(currentExpandedRows, null, 4)}`);
        
        // event.detail:
        // {
        //     "name": "ApexClass",
        //     "isExpanded": true,
        //     "hasChildrenContent": false,
        //     "row": {
        //         "metadataType": "ApexClass",
        //         "hasCalledApi": false,
        //         "_children": []
        //     }
        // }
        if(!event.detail.row.hasCalledApi) {
            console.log(`I haven't called the Metadata API yet for this metadataType, I'm doin' it!!`);
            console.log(`mdType: ${mdType}`);
            retrieveListMetadata({ metadataTypeName: mdType })
            .then(result => {
                const listMetaResult = JSON.parse(result);
                console.log(`List Metadata Result: ${JSON.stringify(listMetaResult, null, 4)}`);
                // Find gridData node, set hasCalledApi to true, and populate it with children
                const idxCurrentNode = this.gridData.findIndex(node => {
                    // console.log(`node: ${JSON.stringify(node, null, 4)}`);
                    return node.metadataType === mdType;
                });
                console.log(`idxCurrentNode: ${idxCurrentNode}`);
                const updatedNode = { ...this.gridData[idxCurrentNode] };
                updatedNode.hasCalledApi = true;
                const childrenArray = listMetaResult.map(result => {
                    return {
                        metadataType: result.fullName,
                        hasCalledApi: true,
                        inFolder: false
                    };
                });
                console.log(`childrenArray: ${JSON.stringify(childrenArray, null, 4)}`);
                updatedNode._children = childrenArray;
                const updatedGridData = [...this.gridData];
                console.log(`updatedNode: ${JSON.stringify(updatedNode, null, 4)}`);
                updatedGridData[idxCurrentNode] = updatedNode;
                console.log(`updatedGridData[idxCurrentNode]: ${JSON.stringify(updatedGridData[idxCurrentNode], null, 4)}`);
                this.gridData = [...updatedGridData];
                
                const setCurrentExpandedRows = new Set(currentExpandedRows);
                if(setCurrentExpandedRows.has(mdType)) {
                    // If toggled node was already in expanded rows, remove
                    setCurrentExpandedRows.delete(mdType);
                } else {
                    // If toggled node was not already in expanded rows, add
                    setCurrentExpandedRows.add(mdType);
                }
                this.expandedRows = Array.from(setCurrentExpandedRows);
            })
            .catch(error => {
                console.error(`List Metadata Error: ${JSON.stringify(error, null, 4)}`);
            });
        }
        
        
    }
    
    handleRowSelection(event) {
        console.log('Somebody selected something!');
    }
}