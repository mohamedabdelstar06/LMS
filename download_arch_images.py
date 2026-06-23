import base64
import requests
import os
from pathlib import Path
from tempfile import gettempdir

# Mermaid Graph for Backend Layered Architecture
graph_layered = """
%%{init: {'themeVariables': { 'fontSize': '24px', 'fontFamily': 'Arial', 'primaryTextColor': '#000000', 'lineColor': '#000000'}}}%%
graph TD
    classDef pres fill:#e1f5fe,stroke:#0277bd,stroke-width:3px,color:#000000,font-size:22px,font-weight:bold;
    classDef biz fill:#ffffff,stroke:#0277bd,stroke-width:3px,color:#000000,font-size:22px,font-weight:bold;
    classDef data fill:#f5f5f5,stroke:#000000,stroke-width:3px,color:#000000,font-size:22px,font-weight:bold;
    classDef core fill:#eceff1,stroke:#607d8b,stroke-width:3px,color:#000000,font-size:22px,font-weight:bold;
    classDef layerBox fill:none,stroke:#01579b,stroke-width:4px,stroke-dasharray: 5 5,color:#000000,font-size:26px,font-weight:bold;

    subgraph PresentationLayer [Presentation Layer]
        direction TB
        Controllers[Controllers]:::pres
        Hubs[Hubs]:::pres
        Middleware[Middleware]:::pres
        Filters[Filters]:::pres
        wwwroot[wwwroot]:::pres
    end
    class PresentationLayer layerBox

    subgraph BusinessLogicLayer [Business Logic Layer]
        direction TB
        Services_Interfaces[Services/Interfaces]:::biz
        Services_Implementation[Services/Implementation]:::biz
        Services_TextPipeline[Services/TextPipeline]:::biz
        Helpers[Helpers]:::biz
    end
    class BusinessLogicLayer layerBox

    subgraph DataAccessLayer [Data Access Layer]
        direction TB
        Data[Data Context]:::data
        Entities[Entities]:::data
        DTOs[DTOs]:::data
        Mapping[Mapping]:::data
        Migrations[Migrations]:::data
    end
    class DataAccessLayer layerBox

    subgraph CoreConfiguration [Core Configuration]
        direction TB
        Configurations[Configurations]:::core
        Extentions[Extentions]:::core
        Properties[Properties]:::core
    end
    class CoreConfiguration layerBox

    Controllers --> Services_Interfaces
    Hubs --> Services_Interfaces
    Filters --> Helpers

    Services_Interfaces -.-> Services_Implementation
    Services_Implementation --> Services_TextPipeline
    
    Services_Implementation --> Data
    Services_Implementation --> DTOs
    DTOs <--> Mapping
    Mapping <--> Entities
    
    Data --> Entities
    Data --> Migrations

    linkStyle default stroke:#000000,stroke-width:4px;
"""

# Mermaid Graph for System Architecture (Vertical layout instead of LR)
graph_system = """
%%{init: {'themeVariables': { 'fontSize': '24px', 'fontFamily': 'Arial', 'primaryTextColor': '#000000', 'lineColor': '#000000'}}}%%
graph TD
    classDef flutter fill:#e1f5fe,stroke:#0277bd,stroke-width:3px,color:#000000,font-size:22px,font-weight:bold;
    classDef backend fill:#ffffff,stroke:#01579b,stroke-width:3px,color:#000000,font-size:22px,font-weight:bold;
    classDef ds fill:#f5f5f5,stroke:#000000,stroke-width:3px,color:#000000,font-size:22px,font-weight:bold;
    classDef external fill:#ffffff,stroke:#000000,stroke-width:3px,color:#000000,stroke-dasharray: 4 4,font-size:22px,font-weight:bold;
    classDef db fill:#ffffff,stroke:#01579b,stroke-width:3px,color:#000000,font-size:22px,font-weight:bold;
    classDef box fill:none,stroke:#000000,stroke-width:4px,stroke-dasharray: 5 5,color:#000000,font-size:26px,font-weight:bold;

    subgraph FlutterClient [Flutter Web Client]
        direction TB
        F_lib[lib: core, features, generated]:::flutter
        F_assets[assets: fonts, icons, images, logo, test_images]:::flutter
        F_test[test]:::flutter
        F_plat[web, windows, android]:::flutter
    end
    class FlutterClient box

    subgraph SkyLearnBackend [SkyLearnApi Backend]
        direction TB
        B_API[API: Controllers, Hubs, Middleware, Filters, wwwroot]:::backend
        B_Logic[Business Logic: Services, Helpers]:::backend
        B_Data[Data Access: Data, Entities, DTOs, Mapping, Migrations]:::backend
        B_Config[Core Config: Configurations, Extentions, Properties]:::backend
        
        B_API --> B_Logic
        B_Logic --> B_Data
        B_Config -.-> B_API
    end
    class SkyLearnBackend box

    subgraph DataScience [Data Science Pipeline]
        direction TB
        D_Data[Data Prep: data, features, generators]:::ds
        D_ML[Machine Learning: ml, analytics]:::ds
        D_Pipe[Pipeline Execution: pipeline, config, utils]:::ds
        
        D_Data --> D_ML
        D_ML --> D_Pipe
    end
    class DataScience box

    subgraph Infra [Infrastructure and External]
        direction TB
        DB[(SQL Server Database)]:::db
        Gemini[Google Gemini API]:::external
        Whisper[Whisper.net Local]:::external
        SMTP[Gmail SMTP]:::external
    end
    class Infra box

    F_lib -->|HTTPS / WebSockets| B_API
    B_Data -->|TCP 1433| DB
    B_Logic --> Gemini
    B_Logic --> Whisper
    B_Logic --> SMTP
    
    DB -->|Audit Logs| D_Data

    linkStyle default stroke:#000000,stroke-width:4px;
"""

def generate_mermaid_image(graph_str, output_path):
    print(f"Generating image for {output_path}...")
    b64 = base64.urlsafe_b64encode(graph_str.encode('utf8')).decode('ascii')
    
    url = f"https://mermaid.ink/img/{b64}?type=png&bgColor=FFFFFF"
    
    response = requests.get(url)
    if response.status_code == 200:
        with open(output_path, 'wb') as f:
            f.write(response.content)
        print(f"Successfully saved to {output_path}")
        with open('error.txt', 'w', encoding='utf-8') as err_f:
            err_f.write(response.text)
        print(f"Failed to generate image. Error written to error.txt")

if __name__ == "__main__":
    temp_dir = Path(gettempdir()) / "lms_req_doc_assets"
    temp_dir.mkdir(parents=True, exist_ok=True)
    
    system_arch_temp_path = temp_dir / "system_architecture.png"
    system_arch_main_path = Path("C:/Users/MK/Documents/LMS/system_architecture.png")
    layered_arch_path = Path("C:/Users/MK/Documents/LMS/Backend/layered_architecture.png")
    
    generate_mermaid_image(graph_layered, layered_arch_path)
    generate_mermaid_image(graph_system, system_arch_temp_path)
    generate_mermaid_image(graph_system, system_arch_main_path)
    
    print("\nDONE!")
