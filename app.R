library(shiny)
library(magrittr)
library(ape)
library(ggtree)
library(gridExtra)
library(cowplot)

#mammals <- read.tree("mammal_raxml_bmc_paper_data/alltrees.tre")

#get species list
#species <- sort(as.character(mammals[[1]]["tip.label"][[1]]))

#set root for each tree
#for (i in 1:length(mammals)){
#  mammals[[i]]<-root(mammals[[i]], outgroup = "Opossum", resolve.root = TRUE)
#}



# Define UI
ui <- fluidPage(
  
  # Application title
  titlePanel("Comparing clades for phylogenies"),
  
  # Sidebar with a slider input for number of bins 
  sidebarLayout(
    sidebarPanel(
      p("This app allows you to compare phylogenies generated from different datasets.
        Use the default datasets of mammals (from Schwartz et al. 2015) or upload your own.
        Select an outgroup to root the tree.
        Given a selection of two species, the app will highlight the smallest clade containing
        those two species."),
      # selectInput("select", h3("Select species"), 
      #             choices = species, multiple = TRUE,
      #             selected = c(species[1], species[2])
      # ),
      fileInput("file", h3("Upload your own trees")),
      
      uiOutput("outgroup"),# from objects created in server
      
      uiOutput("select"),#add selectinput boxs
      
      selectInput("hilite", h3("Select which to highlight"), 
                  choices = c("Clade","Species"),selected = "Clade"
      ),
      radioButtons("brlens", h3("Show Branch Lengths"),
                   choices = list("Brlens" = 1, "Cladogram" = 2),
                   selected = 1
                   )
      
    ),
    
    mainPanel(
      plotOutput("phyloPlot", height="auto")
    )
  )
)

server <- function(input, output, session) {
  
  #read tree either default or uploaded
  mammals <- reactive({

     if (is.null(input$file)){
       #Schwartz et al BMC Bioinf 2015 results
       return(read.tree("mammal_raxml_bmc_paper_data/alltrees.tre"))
     }
     else{
       return(read.tree(input$file$datapath))
     }
     
   })
   
   #get species list
   species <- reactive({
     sort(as.character(mammals()[[1]]["tip.label"][[1]]))
   })
   
  output$select = renderUI({ #creates select box object called in ui
    spp <- species()
    selectInput(inputId = "select", #name of input
                label = "Select two species:", #label displayed in ui
                choices = spp, multiple = TRUE,
                # calls unique values from the State column in the previously created table
                selected = c(spp[1],spp[2]) #default choice (not required)
    )
  })
  
  output$outgroup = renderUI({
    selectInput(inputId = "outgroup", #name of input
                label = "Select outgroup:", #label displayed in ui
                choices = species()
                # calls unique values from the State column in the previously created table
                #selected = c(species[length(species)]) #default choice (not required)
    )
    
  })
  #set root for each tree
  mammals2 <- reactive({
    trees <- mammals() #get trees
    numtrees <- length(trees) #number of trees
    m <- vector("list", numtrees) #empty vector to hold rooted trees
    
    for (i in 1:numtrees){
        m[[i]]<-root(trees[[i]], outgroup = input$outgroup, resolve.root = TRUE)
    }
    m
  })
  
  #Prompt to select species to get mrca/clade for
  families <- reactive({
    validate(
      need(length(input$select) == 2, 
           "Please select two families to highlight the clade containing their MRCA")
    )
    input$select
  })
  
  p <- reactive({
    trees <- mammals2()
    myplots <- vector("list", length(trees))
    
    for (i in 1:length(trees)){
      mrca <- MRCA(trees[[i]], tip=families())
      cladetree <- groupClade(trees[[i]], .node=mrca)
      if(input$brlens == 1){
        myplots[[i]] <- ggtree(cladetree, aes(color=group, linetype=group))+ 
          geom_tiplab() + 
          scale_color_manual(values=c("black", "red")) 
      }
      else{
        myplots[[i]] <- ggtree(cladetree, aes(color=group, linetype=group), branch.length="none")+ 
          geom_tiplab() + 
          scale_color_manual(values=c("black", "red"))
      }
    }
    myplots
  })
  
# #plot 1
#   p1 <- reactive({
#     # get MRCA
#     mrca <- MRCA(mammals[[10]], tip=families())
#     
#     cladetree <- groupClade(mammals[[10]], .node=mrca)
#     if(input$hilite == "Clade"){
#       ggtree(cladetree, aes(color=group, linetype=group))+ 
#       geom_tiplab() + 
#       scale_color_manual(values=c("black", "red")) 
#      }
#     
#     else{
#     #if(input$hilite == "Species"){
#       mrcatree <- groupOTU(cladetree, .node=mrca)
#       ggtree(mrcatree, aes(color=group)) + geom_tiplab()+ 
#         scale_color_manual(values=c("black", "red"))
#     }
#   })
#   
  
  output$phyloPlot <- renderPlot({
    plot_grid(plotlist = p(), ncol=2)
    #grid.arrange(grobs=p(),ncol=4)  
  },
  height = function() {
    2*session$clientData$output_phyloPlot_width
  }
  )
  
}

# Run the application 
shinyApp(ui = ui, server = server)
