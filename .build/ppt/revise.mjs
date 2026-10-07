import fs from 'node:fs/promises';
import path from 'node:path';
import { pathToFileURL } from 'node:url';
import { FileBlob, PresentationFile } from '@oai/artifact-tool';
const root=process.cwd(), skill='/Users/reesefarquharson/.codex/plugins/cache/openai-primary-runtime/presentations/26.909.12148/skills/presentations';
const source=path.join(root,'.build/ppt/source.pptx');
const p=await PresentationFile.importPptx(await FileBlob.load(source));
const ids=['sh/ozy1ofad','sh/d0jax03i','sh/0ba143al','sh/cf2tcr61','sh/zi98nu94','sh/dcbud0ra','sh/g72x4zyd','sh/0b65obm9','sh/cbu58j2h'];
const text=[
'Data: 3,000,000 flight-level records with FL_DATE and DEP_DELAY. Cleaning retained 2,922,356 flights with nonmissing date and departure delay.\nObserved calendar: 1,704 daily intervals from 2019-01-01 to 2023-08-31.\nDelayed flight: DEP_DELAY > 0 minutes.\nMean departure delay: 10.123 minutes. Empirical SD: 49.252 minutes.\nDelayed flights: 992,843, or 33.974%.',
'Use: high-delay days in a fixed 10-day period.\nOwn-data success: daily delayed-flight rate > 40%.\nEstimated p = 0.275235; E[X] = 2.752; Var(X) = 1.995.\nSimulation, 10,000 draws: mean = 2.756; variance = 1.989.\nMGF: M_X(t) = (1-p+p e^t)^n, t in R.\nTheory: Blitzstein and Hwang (2019).',
'Own-data outcome: delayed flights per observed day.\nlambda = 582.654; empirical variance = 73,845.030; empirical SD = 271.744.\nPoisson theoretical variance = 582.654; variance-to-mean ratio = 126.739.\nSimulation mean = 582.747; simulation variance = 583.783.\nMGF: M_X(t) = exp{lambda(e^t-1)}, t in R.\nTheory: Blitzstein and Hwang (2019).',
'Own-data success: at least 10% of a day’s flights have DEP_DELAY > 30 minutes.\np = 0.487676; E[X] = 2.051 days; Var(X) = 2.154.\nSimulation mean = 2.061; simulation variance = 2.165.\nMGF: M_X(t) = p e^t / [1-(1-p)e^t], t < -log(1-p).\nTheory: Blitzstein and Hwang (2019).',
'Own-data success: a delayed flight, DEP_DELAY > 0.\nr = 5; p = 0.339741; E[X] = 14.717 flights; Var(X) = 28.602.\nSimulation mean = 14.748; simulation variance = 28.426.\nMGF: [p e^t / {1-(1-p)e^t}]^r, t < -log(1-p).\nTheory: Blitzstein and Hwang (2019).',
'Own-data population: N = 2,922,356; delayed flights K = 992,843; sample n = 100.\nE[X] = 33.974; Var(X) = 22.431.\nSimulation mean = 33.932; simulation variance = 22.539.\nMGF: sum over support of e^(tx) P(X=x), t in R.\nTheory: Blitzstein and Hwang (2019).',
'Peer-reviewed journal article: Mitsokapas, Schäfer, Harris, and Beck (2021), Scientific Reports.\nThe study statistically characterized arrival delays at UK airports during 2018–2020 and reported broad delay behavior.\nConnection: the project’s daily count variance greatly exceeds its Poisson mean, so a simple Poisson model is a benchmark rather than a fitted conclusion.\nMueller and Chatterji (2002) remains background: it is an AIAA technical-forum paper, not the journal article used here.',
'The flight-level results support five distinct probability experiments.\nPoisson provides a count benchmark but overdispersion is substantial.\nRevised daily-rate thresholds avoid the earlier degenerate Binomial and Geometric results.\nAll five 10,000-draw simulations closely match their theoretical moments.\nInterpret results as describing this sample, not every scheduled U.S. flight.',
'Blitzstein, J. K., & Hwang, J. (2019). Introduction to Probability (2nd ed.). Chapman and Hall/CRC.\nMitsokapas, E., Schäfer, B., Harris, R. J., & Beck, C. (2021). Statistical characterization of airplane delays. Scientific Reports, 11, 7855. https://doi.org/10.1038/s41598-021-87279-8\nMueller, E. R., & Chatterji, G. B. (2002). Analysis of aircraft arrival and departure delay characteristics. AIAA ATIO Technical Forum, AIAA 2002-5866. https://doi.org/10.2514/6.2002-5866\nFlight-level data: flights_sample_3m.csv, source citation to be completed from original download.'
];
ids.forEach((id,i)=>p.resolve(id).text = text[i]);
const plots=[['Poisson simulation','simulation_poisson.png'],['Binomial simulation','simulation_binomial.png'],['Geometric simulation','simulation_geometric_days.png'],['Negative Binomial simulation','simulation_negative_binomial_trials.png'],['Hypergeometric simulation','simulation_hypergeometric.png']];
for(const [title,file] of plots){
 const s=p.slides.add(); s.background.fill='#FFFFFF';
 const titleShape=s.shapes.add({geometry:'textbox',position:{left:67,top:38,width:1152,height:65},fill:'none',line:{fill:'none',width:0}});
 titleShape.text=title; titleShape.text.style={fontSize:34,bold:true,color:'#1F4E79',typeface:'Aptos Display'};
 const bytes=await fs.readFile(path.join(root,'output/figures',file));
 s.images.add({blob:bytes,contentType:'image/png',alt:title,fit:'contain',position:{left:130,top:115,width:1020,height:535}});
 s.speakerNotes.textFrame.setText('Simulation uses 10,000 draws and random seed 562. Source: project output/results/simulation_summary.csv.');
}
const cand=path.join(root,'.build/ppt/candidate.pptx'); await (await PresentationFile.exportPptx(p)).save(cand);
const {finalizePresentation}=await import(pathToFileURL(path.join(skill,'container_tools/artifact_tool_utils.mjs')).href);
await fs.mkdir(path.join(root,'presentation_redo'),{recursive:true});
await finalizePresentation({workspaceDir:root,candidatePath:cand,finalPath:path.join(root,'presentation_redo','STAT562_Discrete_Distributions_Presentation_Revised.pptx'),pythonExecutable:'/Users/reesefarquharson/.cache/codex-runtimes/codex-primary-runtime/dependencies/python/bin/python3',integrityValidatorPath:path.join(skill,'container_tools/inspect_presentation_package_integrity.py'),layoutValidatorPath:path.join(skill,'container_tools/inspect_presentation_layout_geometry.py'),requiredNativeTableOwnerSlides:[],fontPolicy:{basis:'design',families:['Calibri','Aptos Display']},verifyArtifactToolImport:true,receiptPath:path.join(root,'.build/ppt/validation.json')});
