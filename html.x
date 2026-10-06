<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="UTF-8">
<meta name="viewport" content="width=device-width,initial-scale=1.0">
<title>AI Crop Disease Detection</title>
<style>
*{box-sizing:border-box}body{margin:0;font-family:Arial,sans-serif;background:#f3f8f2;color:#26352a}
header{background:#247a3b;color:#fff;text-align:center;padding:24px 15px}header h1{margin:0 0 7px}
.container{max-width:950px;width:92%;margin:28px auto}.card{background:#fff;border-radius:16px;padding:24px;margin-bottom:24px;box-shadow:0 4px 16px #0001}
h2{color:#247a3b;margin-top:0}label{display:block;font-weight:bold;margin:15px 0 7px}
input,select{width:100%;padding:12px;border:1px solid #ccd6cc;border-radius:8px;font-size:15px}
button{width:100%;padding:14px;margin-top:18px;border:0;border-radius:8px;background:#247a3b;color:#fff;font-size:16px;font-weight:bold;cursor:pointer}
button:disabled{background:#9aa99d}.preview{display:none;width:100%;max-height:350px;object-fit:contain;margin-top:15px;border-radius:10px;border:1px solid #ddd}
.msg{display:none;margin-top:14px;padding:12px;border-radius:8px;text-align:center}.error{background:#ffe5e5;color:#900}.success{background:#e5f7e8;color:#17652a}
.loading{display:none;text-align:center;margin-top:15px;color:#247a3b;font-weight:bold}.result{display:none}
.box{border-left:6px solid #247a3b;background:#f7fbf7;padding:20px;border-radius:10px}.item{margin:14px 0}
.item strong{display:block;color:#247a3b;margin-bottom:5px}.badge{display:inline-block;padding:7px 12px;border-radius:20px;background:#fff0c9;color:#765400;font-weight:bold}
.conf{font-size:25px;font-weight:bold}table{width:100%;border-collapse:collapse}th,td{padding:10px;border-bottom:1px solid #ddd;text-align:left}
th{background:#edf6ee}.note{font-size:13px;color:#666;line-height:1.5;margin-top:15px}code{background:#eee;padding:2px 4px;border-radius:3px}
@media(max-width:600px){.container{width:95%}.card{padding:18px}th,td{font-size:12px;padding:7px}}
</style>
</head>
<body>

<header>
<h1>🌱 AI Crop Disease Detection</h1>
<p>Upload a crop/leaf photo and detect possible disease</p>
</header>

<div class="container">

<div class="card">
<h2>📷 Upload Disease Photo</h2>

<form id="form">
<label for="crop">Crop Type *</label>
<select id="crop" required>
<option value="">Select Crop</option>
<option>Tomato</option><option>Rice</option><option>Cotton</option>
<option>Chilli</option><option>Potato</option><option>Maize</option>
</select>

<label for="location">Location (Optional)</label>
<input id="location" placeholder="Example: Tirupati">

<label for="photo">Crop / Leaf Disease Photo *</label>
<input id="photo" type="file" accept="image/*" required>

<img id="preview" class="preview" alt="Uploaded crop photo">

<button id="detect" type="submit">🤖 Detect Disease From Photo</button>

<div id="loading" class="loading">⏳ Uploading photo and analyzing...</div>
<div id="error" class="msg error"></div>
<div id="success" class="msg success"></div>

<p class="note">
<strong>How it works:</strong> The selected image is prepared as a multipart upload.
When your Spring Boot + AI model is connected, the image will be sent to
<code>/api/disease/detect</code> and the returned disease prediction will be shown below.
</p>
</form>
</div>

<div id="result" class="card result">
<h2>🔬 AI Detection Result</h2>
<div class="box">
<div class="item"><strong>Crop</strong><span id="rCrop"></span></div>
<div class="item"><strong>Crop Life Span</strong><span id="rLife"></span></div>
<div class="item"><strong>Disease / Healthy Status</strong><span id="rDisease" class="badge"></span></div>
<div class="item"><strong>Confidence</strong><span id="rConfidence" class="conf"></span></div>
<div class="item"><strong>Diagnosis Message</strong><p id="rDiagnosis"></p></div>
<div class="item"><strong>Recommended Next Action</strong><p id="rAction"></p></div>
<div class="item"><strong>Location</strong><span id="rLocation"></span></div>
</div>
</div>

<div class="card">
<h2>📊 Detection History</h2>
<div style="overflow-x:auto">
<table>
<thead><tr><th>Crop</th><th>Disease</th><th>Confidence</th><th>Location</th></tr></thead>
<tbody id="history"></tbody>
</table>
</div>
</div>

</div>

<script>
/*
 * ================================
 * REAL AI BACKEND CONFIGURATION
 * ================================
 *
 * Change this URL to your Spring Boot server.
 * Example:
 * http://localhost:8080/api/disease/detect
 *
 * The backend should accept multipart/form-data:
 * cropType, location, image
 *
 * Expected JSON:
 * {
 *   "crop": "Tomato",
 *   "lifeSpan": "3-6 months",
 *   "disease": "Early Blight",
 *   "confidence": 94.5,
 *   "diagnosis": "Possible Early Blight detected.",
 *   "nextAction": "Consult an agricultural expert."
 * }
 */
const API_URL = "http://localhost:8080/api/disease/detect";

/*
 * Set to true while the backend/AI model is not ready.
 * Set to false when your Spring Boot API is running.
 */
const DEMO_MODE = true;

const form=document.getElementById("form");
const crop=document.getElementById("crop");
const locationInput=document.getElementById("location");
const photo=document.getElementById("photo");
const preview=document.getElementById("preview");
const detect=document.getElementById("detect");
const loading=document.getElementById("loading");
const error=document.getElementById("error");
const success=document.getElementById("success");

const demoData={
Tomato:{lifeSpan:"3–6 months",disease:"Early Blight",confidence:94.5,diagnosis:"The uploaded tomato leaf may show symptoms associated with Early Blight.",nextAction:"Monitor the crop and consult an agricultural expert for confirmation."},
Rice:{lifeSpan:"3–6 months",disease:"Leaf Blast",confidence:91.2,diagnosis:"The uploaded rice leaf may show symptoms associated with Leaf Blast.",nextAction:"Monitor the crop and seek appropriate agricultural advice."},
Cotton:{lifeSpan:"6–9 months",disease:"Bacterial Blight",confidence:89.7,diagnosis:"The uploaded cotton leaf may show signs associated with Bacterial Blight.",nextAction:"Consult an agricultural expert before treatment."},
Chilli:{lifeSpan:"6–12 months",disease:"Leaf Spot",confidence:87.8,diagnosis:"The uploaded chilli leaf may indicate a possible leaf-spot condition.",nextAction:"Inspect nearby plants and consult an agricultural expert."},
Potato:{lifeSpan:"3–4 months",disease:"Late Blight",confidence:92.6,diagnosis:"The uploaded potato leaf may show symptoms associated with Late Blight.",nextAction:"Monitor the crop and seek professional agricultural advice."},
Maize:{lifeSpan:"3–5 months",disease:"Leaf Blight",confidence:90.1,diagnosis:"The uploaded maize leaf may show symptoms associated with Leaf Blight.",nextAction:"Inspect nearby plants and consult an agricultural expert."}
};

photo.addEventListener("change",()=>{
 const file=photo.files[0];
 hideMessages();
 if(!file){preview.style.display="none";return}
 if(!file.type.startsWith("image/")){photo.value="";showError("Please upload a valid image.");return}
 const reader=new FileReader();
 reader.onload=e=>{preview.src=e.target.result;preview.style.display="block"};
 reader.readAsDataURL(file);
});

form.addEventListener("submit",async e=>{
 e.preventDefault();hideMessages();

 if(!crop.value)return showError("Please select a crop type.");
 if(!photo.files[0])return showError("Please upload a crop/leaf photo.");

 detect.disabled=true;detect.textContent="🔬 Analyzing Photo...";
 loading.style.display="block";

 try{
   let result;

   if(DEMO_MODE){
     await new Promise(r=>setTimeout(r,1500));
     result=demoData[crop.value];
   }else{
     const data=new FormData();
     data.append("cropType",crop.value);
     data.append("location",locationInput.value.trim());
     data.append("image",photo.files[0]);

     const response=await fetch(API_URL,{method:"POST",body:data});
     if(!response.ok){
       let message="Disease detection request failed.";
       try{const e=await response.json();message=e.message||message}catch(_){}
       throw new Error(message);
     }
     result=await response.json();
   }

   showResult(result,crop.value,locationInput.value.trim()||"Not provided");
   showSuccess(DEMO_MODE
     ?"Prototype prediction completed. Connect the AI backend for real image-based detection."
     :"AI disease detection completed successfully.");
 }catch(err){
   showError(err.message+" Make sure your Spring Boot server is running.");
 }finally{
   loading.style.display="none";
   detect.disabled=false;
   detect.textContent="🤖 Detect Disease From Photo";
 }
});

function showResult(data,cropName,location){
 document.getElementById("rCrop").textContent=data.crop||cropName;
 document.getElementById("rLife").textContent=data.lifeSpan||"Not available";
 document.getElementById("rDisease").textContent=data.disease||data.status||"Unknown";
 document.getElementById("rConfidence").textContent=
   typeof data.confidence==="number"?data.confidence+"%":(data.confidence||"N/A");
 document.getElementById("rDiagnosis").textContent=data.diagnosis||"No diagnosis message returned.";
 document.getElementById("rAction").textContent=data.nextAction||data.action||"Consult an agricultural expert.";
 document.getElementById("rLocation").textContent=location;

 const badge=document.getElementById("rDisease");
 badge.classList.toggle("healthy",(data.disease||data.status)==="Healthy");

 document.getElementById("result").style.display="block";

 const row=document.createElement("tr");
 [data.crop||cropName,data.disease||data.status||"Unknown",
  typeof data.confidence==="number"?data.confidence+"%":data.confidence||"N/A",location]
 .forEach(v=>{const td=document.createElement("td");td.textContent=v;row.appendChild(td)});
 document.getElementById("history").prepend(row);

 document.getElementById("result").scrollIntoView({behavior:"smooth"});
}

function showError(m){error.textContent=m;error.style.display="block"}
function showSuccess(m){success.textContent=m;success.style.display="block"}
function hideMessages(){error.style.display="none";success.style.display="none"}
</script>
</body>
</html>