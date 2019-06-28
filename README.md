# Just simple example how to make your student life easier

## Why?

In my student activities, I ran into one problem - the constant need to write reports.  
It took a lot of time and became even more of a problem when it was necessary to correct mistakes.   
Automating the creation of reports allowed me and other students to forget about this boring activity.  
Here is one of the early concepts (very simple, a lot of code "in haste") which fully automates the creation of a term paper.     
Due to this, there is no need to think whether everything was correctly added to the report or whether the data was changed during recalculation.  

## How it work?

Matlab script does all the calculations, drives them through the simulimk model, then everything is saved in json file (in this example all fields saved "as it is")  
In the template folder already prepared `tex` template with "tags" (like this: "{{studentName}}").  
After generating the model data file, we use template engine (in our case just a tiny script, which read template and use `replace` function) to insert data into our report template (in our case more data is added from `user_data.json` file, which may contain additional information (student personal data for example)).  
After this templat can be generated into prepared report.  
This is a simple but effective concept that can be expanded and applied where you do not want to constantly engage in paperwork.

## Requirements
* nodejs v8 > (as simple template engine analogue)  
* texlive-latex-base  
* matlab (in example simulink model wath builded in 2018a)  

## How to run?

1. Run `main.m` script in matlab (when you first start it runs longer because it launches simulink and makes many measurements to build a table with the substitution of various values)  
2. Copy `model_data.json` file to folder with `index.js` (or change path into `index.js` script to data files)
3. `npm start`
4. `cd build/ && pdflatex builded.tex`

For image use in our case in folder `build` and `template` there is an `images` folder, where all the necessary images are stored.   
In `template.tex` you can edit `\graphicspath{ {./images/} }` for new path and insert image using `\includegraphics{fileName}`
## Tips and tricks

### How to automaticly generate charts from simulink?
Just save simulink output to matlab variable, then:  
```
% outputSignal - saved output from simulink
figure;
plot(outputSignal.Time, outputSignal .Data);
% setup y and x axis limits
ylim([-1 1]);
xlim([-1 1]);
saveas(gcf,'outputSignal.jpg');
close;
```
### How to automaticly make screenshot of simulink model?
Create model file `modelName.slx`, which contains only one model, then:
```
modelName
print('-smodelName','-djpeg','modelName')
close_system;
```

