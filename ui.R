
# The shinyalert and showshinyalert are taken from AnalytixWare/ShinySky 
#  by xiaodaigh and adapted by Peter Kruczkiewicz (https://bitbucket.org/peterk87/qviz)

# http://shiny.rstudio.com

packrat::on()
library(shiny)
library(rCharts)
library(d3heatmap)
library(leaflet)

# tags$link(rel="shortcut icon" href="/favicon.ico" type="image/x-icon"),
# <link rel="icon" href="/favicon.ico" type="image/x-icon">
######################## *******************************  ************************************** ################
#                                            SHINY UI START                                                     #
######################## *******************************  ************************************** ################  
shinyUI(
  navbarPage(
                   # theme = "united.css", 
                   fluid = T, 
                   title = "EpiQuant",
                   inverse = T, 
                   footer=a(href="https://github.com/hetmanb/EpiQuant", "Questions?"),
######################## *******************************  ************************************** ################
#                                            NavTab for Source-Matrix                                           #
######################## *******************************  ************************************** ################                   
                  tabPanel("SourceMatrix",
                      pageWithSidebar(
                        # Application title
                        headerPanel("Source Analysis using Epi-Matrix",
                                    # load javascript files 
                                    tags$head(
                                      tags$script(src="lib/underscore.js"),
                                      tags$script(src="js/mapper.js"),
                                      tags$script(src ="js/chord.js"),
                                      tags$script(src ="js/chord2.js"),
                                      tags$script(src ="www/lib/leaflet.js")
                                    )
                              ),
                        # Sidebar with a slider input for number of observations
                        sidebarPanel(width = 4
                                             ,h4("SourceMatrix Options")
                                             ,p("SourceMatrix is a method of coming up with pairwise similarity indices based on a subjective scoring matix")
                                             ,p("First, you'll need to download the", shiny::a("template file.", href= "https://www.dropbox.com/s/bkgvhi00y76w02d/source_scorings.txt?dl=1"))
                                             ,br()
                                             ,p("Once you've downloaded the file, open it in your favorite spreadsheet software and start filling in the boxes using the following rules.")
                                             ,code("1 = Strongly Correlated")
                                             ,code("0 = Strongly Uncorrelated")
                                             ,code("7 = Possibly Correlated (Wildcard)")
                                             ,br()
                                             ,checkboxInput(inputId = "source_demo", label = "Use demo data", value = TRUE)
                                             ,br()
                                             ,p("Upload your similarity scoring matrix here:")
                                             ,fileInput(inputId="source_scores",label="Upload",multiple=FALSE,accept=".txt")
                                             ,h4("These sliders pertain to the epi-matrix using a summation approach:")
                                             ,sliderInput(inputId="mod7",label="Modifier for 7-0 match", min=0, max=1.0, value=0.15, step=0.05)
                                             ,sliderInput(inputId="mod8",label="Modifier for 7-1 match", min=0, max=1.0, value=0.35, step=0.05)
                                             ,sliderInput(inputId="mod0",label="Modifier for 0-0 match", min=0, max=1.0, value=0.95, step=0.05)
                                             ,sliderInput(inputId="mod14",label="Modifier for 7-7 match", min=0, max=1.0, value=0.15, step=0.05)
                                             ,submitButton("Submit", icon = NULL)
                                           ),
                        # Show a table of the uploaded data: 
                        mainPanel(
                          tabsetPanel(
                            id = 'conditionedPanels',
                            tabPanel("Source Table",
                                     br(),
                                     DT::dataTableOutput("scoretable")
                            ),                            
                            tabPanel("Source Heatmap",
                                     h3("Heatmap based on the source scorings and the penalty sliders from the sidebar"),
                                     downloadButton("downloadSourceHeatmap", "Download Heatmap"),
                                     downloadButton("downloadSourceMatrix", "Download Full Matrix File"),
                                     downloadButton("downloadSourcePairwise", "Download Pairwise File"),
                                     br(),
                                     d3heatmapOutput("source_heatmap", width=750, height=750)
                                     ),
                            tabPanel("Source Chord",
                                      h4("The chord diagram shows the source-relationships that fall within the low-and-high thresholds"),
                                      br(), 
                                      sliderInput("chord_low", "Low Threshold for Similarity", min=0, max=1.0, value=0.7, step=0.01), 
                                      sliderInput("chord_high", "High Threshold for Similarity", min=0, max=1.0, value=1, step=0.01),
                                      br(),
                                      div(id = 'jschord', class = 'jschord')
                            )
                            )
                          ))),
######################## *******************************  ************************************** ################
#                                            NavTab for Epi-Matrix                                              #
######################## *******************************  ************************************** ################
                   tabPanel("EpiMatrix",
                            pageWithSidebar(                              
                              # Application title
                              headerPanel("Epi-Matrix: Similarity Scoring using Epidemiological Data"),
                              
                              # Sidebar with a slider input for number of observations
                              sidebarPanel(h4("Epi-Matrix: Similarity Scoring using Epidemiological Data"), 
                                           p("This app will take the source, temporal, and geographical data from your input dataset and compute
                                             numerical similarity coefficients for each strain"),
                                           p("Here are some template files to get started:"),
                                           shiny::a("Strain Data", href= "https://www.dropbox.com/s/6v5ka88lhtyrt5x/strain_data.txt?dl=1"),
                                           br(),
                                           shiny::a("Source Reference", href= "https://www.dropbox.com/s/hl3kiov5d97dt3a/source_data.txt?dl=1"),
                                           br(),
                                           checkboxInput(inputId = "epi_demo", label = "Use demo data", value = TRUE),
                                           br(),
                                           fileInput(inputId="strain_data",label="Upload Strain Data Here:",multiple=FALSE,accept=".txt"),
                                           fileInput(inputId="source_data",label="Upload Source Reference Here:",multiple=FALSE,accept=".txt"),
                                           h4("Make the following sliders add up to 1.0"),
                                           sliderInput(inputId="source_coeff", label="Coefficient for Source Factor", min=0.0, max=1.0, value=0.5, step=0.05),
                                           sliderInput(inputId="temp_coeff", label="Coefficient for Temporal Factor", min=0.0, max=1.0, value=0.3, step=0.05),
                                           sliderInput(inputId="geog_coeff", label="Coefficient for Geographical Factor", min=0.0, max=1.0, value=0.2, step=0.05),
                                           h4("Optional: For outbreak analyses, input the epidemiological window desired (in number of days)"),
                                           numericInput("outbreak_window", "Outbreak Window:", 0, min = 0, max = 99, step = 1, width = 100),
                                           submitButton("Submit", icon = NULL)
                                           ),
                              
                              
                              # Show a plot of the generated distribution
                              mainPanel(
                                tabsetPanel(
                                  tabPanel(title="Epi-Matrix",
                                           downloadButton("downloadEpiData", "Download Similarity Data"),
                                           downloadButton("downloadEpiTable", "Download Similarity Table"),
                                           downloadButton("downloadEpiHeatmap", "Download Heatmap"),
                                           d3heatmapOutput("EpiHeatmap", width=1000, height=1000)
                                  ),
                                  tabPanel(title="Map", 
                                           tags$style('.leaflet {height: 600px;}'),
                                           chartOutput("epiMap", 'leaflet'))
                                  # tabPanel(title = "Epi Chord Diagram", 
                                  #          h4("This chord diagram shows the epidemiological relationships that fall within the low-and-high thresholds"),
                                  #          br(), 
                                  #          sliderInput("chord2_low", "Low Threshold for Similarity", min=0, max=1.0, value=0.7, step=0.01), 
                                  #          sliderInput("chord2_high", "High Threshold for Similarity", min=0, max=1.0, value=.95, step=0.01),
                                  #          br(),
                                  #          div(id = 'jschord2', class = 'jschord2')
                                  # )
                             )
                            ))),
######################## *******************************  ************************************** ################
#                                            NavTab for CGF-Matrix                                              #
######################## *******************************  ************************************** ################
                   tabPanel("GenMatrix",
                            pageWithSidebar(
                              
                              # Application title
                              headerPanel("Genetic Analysis and Similarity Calculator"),   
                              # Sidebar with a slider input for number of observations
                              sidebarPanel(h4("GenMatrix"),
                                           p("GenMatrix will take either CGF or allelic data (MLST+) from your dataset and calculate the similarity scores for each pairing of strains"),
                                           br(),
                                           selectizeInput("gen_type", "Select your type of data:", 
                                                          list("CGF" = "A", "MLST"="B", "eMLST"="C", "rMLST"="D", "hexMLST"="E")),  
#                                            radioButtons(inputId = "gen_type", label = "Select your type of data:", choices = c("CGF" = 1, "MLST" = 2)), 
#                                            checkboxGroupInput(inputId = "gen_data", label = "Select the type of data you're using:", choices  = c("CGF", "MLST"), inline = F ),
                                           checkboxInput(inputId = "cgf_demo", label = "Use demo data", value = F),
                                           p("Upload your Gene data here:"),
                                           fileInput(inputId="cgf",label="Upload CGF/MLST file",multiple=FALSE,accept=".txt"),
                                           submitButton("Submit", icon = NULL)
                              ),
                              
                              # Show a plot of the generated distribution
                              mainPanel(
                                tabsetPanel(
                                  tabPanel(title="GenMatrix",
                                           h3("Heatmap based on the similarity scorings of your Genomic Data"),
                                           downloadButton("downloadCGFHeatmap", "Download Gene Heatmap"),
                                           downloadButton("downloadCGFTable", "Download Gene Similarity Data"),
                                           br(),
                                           d3heatmapOutput("cgf_heatmap", width=1000, height=1000)) 
                                                                    
                                )
                              )
                            )),
######################## *******************************  ************************************** ################
#                                            NavTab for Comparisons                                             #
######################## *******************************  ************************************** ################
                   tabPanel("Compare",
                            pageWithSidebar(
                              
                              # Application title
                              headerPanel("Compare CGF and Epi Similarity Scorings"),   
                              # Sidebar to upload data from CGF and Epi Matrix Generators 
                              sidebarPanel(h4("Compare Epi with CGF Data"),
                                           p("Input the matrix data from the Epi-Matrix and CGF-Matrix Apps to compare the results"),
                                           p("Strains that are more closely related via their epi-relationships will be shown in", 
                                             span("green",style="color:green"), 
                                             "and those that are more strongly associated genetically will be shown in",
                                             span("blue.",style="color:blue")),
                                           br(),
                                           checkboxInput("compare_demo", "Use demo data", FALSE),
                                           checkboxInput("compare_raw", "Perform raw comparison?", FALSE),
                                           p("Upload your Epi data here:"),
                                           fileInput(inputId="epi_data",label="Upload Epi file",multiple=FALSE,accept=".txt"),
                                           p("Upload your Genetic Similarity (CGF) data here:"),
                                           fileInput(inputId="cgf_data",label="Upload Similarity (CGF) file",multiple=FALSE,accept=".txt"),
                                           sliderInput('cut_epi', "Select the Epi-cut threshold percent", min = 0.01, max = 1.00, step = 0.01, value = 0.90), 
                                           sliderInput('cut_cgf', "Select the Genetic-cut threshold percent", min = 0.01, max = 1.00, step = 0.01, value = 0.90),
                                           p("Check here to select the clustering basis of the output:"),
                                           radioButtons(inputId = "clus_type", label = NULL, choices = list("Genetic"= "A", "Epi" = "B", "Both" = "C"), selected = "C"),                                           
                                           submitButton("Submit", icon = NULL)
                              ),
                              
                              # Show a plot of the generated distribution
                              mainPanel(
                                tabsetPanel(
                                  tabPanel(title="Comparison Heatmap",
                                           h3("Heatmap based on the similarity scorings of your CGF Data versus the Epi Data"),
                                           br(),
                                           downloadButton("downloadCompareHeatmap", "Download the Heatmap"), 
                                           downloadButton("downloadCompareTable", "Download the Comparison Table"),
                                           downloadButton("downloadCompareMatrix", "Download the Comparison Matrix"),
                                           br(),
                                           sliderInput('sigma','Select the Sigma value for displaying outliers on the heatmap', min = 0.1, max = 3, step = 0.01, value = 1),
                                           d3heatmapOutput("compare_heatmap", width=1000, height=1000)
                                           ),
                                  tabPanel(title="TangleGram",
                                           h3("Tanglegram displaying the concordance of the 2 methods"),
                                           downloadButton("DL_tanglegram", "Download Tanglegram pdf"),
                                           br(),
                                           sliderInput('num_k', "Select the number of clusters", min = 1, max = 8, step = 1, value = 4),
#                                            downloadButton("downloadCompareHeatmap", "Download the Heatmap"), 
#                                            downloadButton("downloadCompareTable", "Download the Comparison Table"),
#                                            br(),
                                           plotOutput("tangle", width=1000, height=1000)
                                  )))))
))
