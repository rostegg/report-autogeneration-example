const fs = require('fs')
const path = require('path')
const buildDir = 'build'
let text = ''

const replaceShortcut = (variable, value) => {
    const regex = new RegExp(`{{${variable}}}`, "g")
    text = text.replace(regex,value)
}

const editTemplate = (data) => {
    Object.keys(data).forEach(function(key){
        replaceShortcut(key,data[key])
    })
}

const processModelData = () => {
    
    fs.readFile('model_data.json', (err, data) => {  
        if (err) throw err
        let modelData = JSON.parse(data)
        Object.keys(modelData).forEach(function(key){ 
            if (typeof modelData[key] !== 'string') {
                if (!Number.isInteger(modelData[key]) || modelData[key] > Math.pow(10,6) || modelData[key] < 1/Math.pow(10,10) && modelData[key] !== 0)
                    modelData[key] = modelData[key].toPrecision(4)
            }
            else
                modelData[key] = modelData[key].replace(/_|\*/g,'')
        })
        //console.log(modelData)
        editTemplate(modelData)
        processUserData()
    })
}

const processUserData = () => {
    fs.readFile('user_data.json', (err, data) => {  
        if (err) throw err
        let userData = JSON.parse(data)
        editTemplate(userData)
        saveEditedTemplate()
    })
}

const saveEditedTemplate = () => {
    fs.writeFile(`${buildDir}/builded.tex`, text, function(err) {
        if(err) {
            return console.log(err)
        }
        console.log("Template saved in build dir")
    }); 
}

const loadTemplate = () => {
    fs.readFile('template/template.tex','utf8', (err, data) => {  
        if (err) throw err
        text = data
        processModelData()
    })
}

const clearBuildDir = () => {
    fs.readdir(buildDir, (err, files) => {
        if (err) throw err
        for (const file of files) {
          fs.unlink(path.join(buildDir, file), err => {})
        }
    })
}

clearBuildDir()
loadTemplate()



