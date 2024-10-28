# BeNAV-Biopsy-through-Enhanced-Navigation-and-Augmented-Visualization

This repository contains a prototype app for breast biopsy planning with precise needle navigation and augmented visualization based guidance for the biopsy needle. This prototype was developed in 3 days [Healthcare Hackathon Bayern](https://www.bayern-innovativ.de/de/veranstaltung/healthcare-hackathon-bayern-2024).

&nbsp;
&nbsp;

## Problem Statement
#### Innovating Mammography – Enhancing Precision and Comfort in Needle Insertion for Biopsy by Siemens Healthineers
<div style="text-align: justify"> In the realm of mammography, precise needle insertion is crucial for both diagnostic and therapeutic procedures. However, the current process can be challenging, leading to discomfort and anxiety for patients. We challenge you to transform the mammography journey into a more comfortable and reassuring experience for women. How can it be less daunting and what innovative solutions can be employed to ensure a smoother, more supportive experience for patients? </div>

&nbsp;
&nbsp;

## Pain Points 
- Targeting lessions accurately is difficult from 2D scans as they lack the 3D perception.
- Most of the time is spent over referencing a scan while putting the needle inside, resulting into more time needed for the biopsy procedure which is painful for the patient.
- Patient movement might cause issues in needle guidance through prior scans.
- Needle might pass through critical structures like blood vessels.

&nbsp;
&nbsp;

## Our Proposed Solution
We proposed a solution to the above pain points through an application for accurate 


&nbsp;
&nbsp;

## Conclusion



&nbsp;
&nbsp;

## Further Scopes of Development
- Streamline 2D to 3D Mesh Model
  - Xray/Mammogram to 3D using generative models.
  - Statistical shape modelling.
  - 3D reconstruction using a reference mesh of 3D breast and scaling with respect to measured anterio-posterior, latero-medial and superior-inferior dimensions of the breast through a digital image.
- Fast and continuous 3D registration for the AR App using detected landmarks.
- Simulating breast deformation on the mesh if the patient moves, by tracking relative position change within each landmark.



