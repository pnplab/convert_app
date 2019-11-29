###     -*- Coding: utf-8 -*-          ###
### Analyst Charles-Edouard Giguere   ###

### Shiny application for the article "Converting scores between the PANSS and SAPS/SANS beyond the positive/negative dichotomy" (Grot et al, 2019, PsychArXiv).

### User interface side. 

require(shinyjs)

ui <- pageWithSidebar(

  # App title ----
  headerPanel("SCORE CONVERTER"),

  # Sidebar panel for inputs ----
  sidebarPanel(width = 4,
               fluidRow(
                   column(3,
                          img(src = "pnp.png",width = "100px")
                          ),
                   column(9, h3("PNP LAB"),                         
                          h4("Predictive Neuroimaging in Psychiatry Lab")
                          )
               ),
               selectInput("CORR1",
                           label = "CONVERSION: Choose which scores to convert between scales",
                           multiple = TRUE,
                           choices = c("PANSS_positive => SAPS_total",
					"PANSS_positive => SAPS_summary",
					"PANSS_negative => SANS_total",  
    					"PANSS_negative => SANS_summary", 
 					"PANSS_delusions => SAPS_delusions", 
					"PANSS_disorganization => SAPS_disorganization", 
					"PANSS_hallucinations => SAPS_hallucinations",
					"PANSS_amotivation => SANS_amotivation",
					"PANSS_expressivity => SANS_expressivity", 
					"PANSS_cognition => SANS_cognition", 
					"SAPS_total => PANSS_positive", 
                                       	"SAPS_summary => PANSS_positive", 
                                       	"SANS_total => PANSS_negative", 
					"SANS_summary => PANSS_negative", 
                                       	"SAPS_delusions => PANSS_delusions", 
                                       	"SAPS_disorganization => PANSS_disorganization", 
                                       	"SAPS_hallucinations => PANSS_hallucinations", 
                                       	"SANS_amotivation => PANSS_amotivation",
                                       	"SANS_expressivity => PANSS_expressivity", 
                                       	"SANS_cognition => PANSS_cognition")),
               checkboxInput("fl",
                             label = "Ignore First line",
                             value = FALSE
               ),
               fileInput("FIN",
                         "INPUT: Select file (beware columns must be in the exact same order as given in CONVERSION)",
                         accept=c('text/csv',
                                  'text/comma-separated-values,text/plain',
                                  '.csv')
                         ),
               downloadLink("Download", "Download the output file"),
               br(),
               br(),
               br(),
               a("See Manual",href = "https://github.com/pnplab/convert_app",
                 target = "_blank"),
               br(),
               actionButton("close",
                            "Close App")
               ),

  # Main panel for displaying outputs ----
  mainPanel(fluidRow(column(4,
                            fluidRow(tableOutput("ORDER"),
                                     plotOutput("FIG1"),
                                     actionButton("Next", label = "Next plot"),
                                     useShinyjs()
                                     )
                            ),
                     column(8, tableOutput("OUT1"))                     
                     )

            )
)
  


  
