<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ page import="java.time.LocalDate" %>
    <%
        if (session.getAttribute("username") == null) {
            response.sendRedirect("../LoginPage/login.jsp");
            return;

        }
        LocalDate today = LocalDate.now();
    %>
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>ThriftShop Auction - Main Page</title>
            <link rel="stylesheet" href="../css/auction-style.css">
            <script>
                // Make functions available globally - defined in head so they're available immediately
                function createAuction() {
                    // Try to find existing modal first
                    var modal = document.getElementById('createAuctionModal');
                    
                    if (modal) {
                        // Modal exists, just show it
                        modal.style.display = 'block';
                        modal.style.visibility = 'visible';
                        modal.style.opacity = '1';
                        modal.style.position = 'fixed';
                        modal.style.zIndex = '99999';
                        modal.style.left = '0';
                        modal.style.top = '0';
                        modal.style.width = '100%';
                        modal.style.height = '100%';
                        modal.style.backgroundColor = 'rgba(0, 0, 0, 0.7)';
                        document.body.style.overflow = 'hidden';
                        return;
                    }
                    
                    // If modal doesn't exist, find the form and create modal
                    var formDiv = document.getElementById('auctionFillOutForm');
                    if (!formDiv) {
                        // Try to find it by class
                        formDiv = document.querySelector('.auction-form');
                    }
                    
                    if (!formDiv) {
                        alert('Form not found! Please refresh the page.');
                        console.error('Could not find auctionFillOutForm or .auction-form');
                        return;
                    }
                    
                    // Create modal dynamically
                    modal = document.createElement('div');
                    modal.id = 'createAuctionModal';
                    modal.className = 'modal';
                    modal.style.cssText = 'display: block; position: fixed; z-index: 99999; left: 0; top: 0; width: 100%; height: 100%; overflow: auto; background-color: rgba(0, 0, 0, 0.7);';
                    
                    var modalContent = document.createElement('div');
                    modalContent.className = 'modal-content';
                    modalContent.style.cssText = 'background-color: white; margin: 5% auto; padding: 0; border-radius: 12px; width: 90%; max-width: 900px; max-height: 85vh; overflow-y: auto; box-shadow: 0 10px 25px rgba(0,0,0,0.15); position: relative;';
                    
                    var closeBtn = document.createElement('span');
                    closeBtn.className = 'modal-close';
                    closeBtn.innerHTML = '&times;';
                    closeBtn.onclick = closeAuctionModal;
                    closeBtn.style.cssText = 'color: #7f8c8d; float: right; font-size: 32px; font-weight: bold; position: absolute; right: 20px; top: 15px; z-index: 10001; cursor: pointer; line-height: 1;';
                    
                    modalContent.appendChild(closeBtn);
                    modalContent.appendChild(formDiv.cloneNode(true));
                    modal.appendChild(modalContent);
                    
                    // Close on background click
                    modal.onclick = function(e) {
                        if (e.target === modal) {
                            closeAuctionModal();
                        }
                    };
                    
                    document.body.appendChild(modal);
                    document.body.style.overflow = 'hidden';
                }
                
                function closeAuctionModal() {
                    var modal = document.getElementById('createAuctionModal');
                    if (modal) {
                        modal.classList.remove('show');
                        modal.style.cssText = 'display: none !important;';
                        document.body.style.overflow = "auto";
                    }
                }

                function toggleSearch() {
                    console.log('toggleSearch function called');
                    var searchDiv = document.getElementById('searchSection');
                    var formDiv = document.getElementById('auctionFillOutForm');
                    
                    if (searchDiv) {
                        var currentDisplay = window.getComputedStyle(searchDiv).display;
                        if (currentDisplay === "none") {
                            // Show search section
                            searchDiv.style.display = "block";
                            // Hide auction form if it's visible
                            if (formDiv) {
                                formDiv.style.display = "none";
                            }
                        } else {
                            // Hide search section
                            searchDiv.style.display = "none";
                        }
                    }
                    return false;
                }
            </script>
        </head>
        <body>
            <!-- Header -->
            <header class="header">
                <div class="header-container">
                    <a href="mainPage.jsp" class="logo">🏛️ ThriftShop</a>
            <nav>
                        <ul class="nav-menu">
                    <li><a href="tops.jsp">Tops</a></li>
                    <li><a href="bottoms.jsp">Bottoms</a></li>
                    <li><a href="shoes.jsp">Shoes</a></li>
                    <li><a href="sellers.jsp">Sellers</a></li>
                    <li><a href="notifications.jsp">Notifications</a></li>
                    <li><a href="profile.jsp">Profile</a></li>
                            <li><a href="../LoginPage/logout.jsp">Logout</a></li>
                </ul>
            </nav>
                    <div class="user-info">👤 <%=session.getAttribute("username")%></div>
                </div>
            </header>

            <!-- Main Content -->
            <div class="container">
                <div class="page-header">
                    <h1>Welcome to ThriftShop</h1>
                    <p>Your premium auction marketplace for quality clothing</p>
                </div>
                
                <!-- Action Buttons -->
                <div style="display: flex; gap: 1rem; margin-bottom: 2rem; flex-wrap: wrap;">
                    <button type="button" id="searchBtn" class="btn btn-secondary" style="cursor: pointer; min-width: 150px; color: white;">🔍 Search Items</button>
                    <button type="button" id="createAuctionBtn" onclick="createAuction(); return false;" class="btn btn-primary" style="cursor: pointer; min-width: 150px; color: #1a1f3a; font-weight: 600;">➕ Create Auction</button>
                </div>
            <script>
                document.addEventListener("DOMContentLoaded", function () {
                    // Add event listeners to buttons
                    var createAuctionBtn = document.getElementById('createAuctionBtn');
                    if (createAuctionBtn) {
                        createAuctionBtn.onclick = function(e) {
                            e.preventDefault();
                            createAuction();
                            return false;
                        };
                    }
                    
                    // Close modal when clicking outside
                    var modal = document.getElementById('createAuctionModal');
                    if (modal) {
                        modal.onclick = function(e) {
                            if (e.target === modal) {
                                closeAuctionModal();
                            }
                        };
                    }
                    
                    // Close modal with Escape key
                    document.addEventListener('keydown', function(e) {
                        if (e.key === 'Escape') {
                            closeAuctionModal();
                        }
                    });
                    
                    var searchBtn = document.getElementById('searchBtn');
                    if (searchBtn) {
                        searchBtn.addEventListener('click', function(e) {
                            e.preventDefault();
                            toggleSearch();
                        }, false);
                    }
                    
                    // Search Form Toggling
                    var searchTypeSelect = document.getElementById('searchTypeSelect');
                    if (searchTypeSelect) {
                        searchTypeSelect.addEventListener("change", function () {
                        const value = this.value;
                        const forms = ['searchFormTops', 'searchFormBottoms', 'searchFormShoes', 'searchFormAny'];
                        const buttons = ['searchTopSubmit', 'searchBottomSubmit', 'searchShoeSubmit', 'searchAnySubmit'];

                        forms.forEach(id => {
                            const el = document.getElementById(id);
                            if (el) el.style.display = 'none';
                        });
                        buttons.forEach(id => {
                            const el = document.getElementById(id);
                            if (el) el.style.display = 'none';
                        });

                        if (value === "tops") {
                            document.getElementById('searchFormTops').style.display = "block";
                            document.getElementById('searchTopSubmit').style.display = "block";
                        } else if (value === "bottoms") {
                            document.getElementById('searchFormBottoms').style.display = "block";
                            document.getElementById('searchBottomSubmit').style.display = "block";
                        } else if (value === "shoes") {
                            document.getElementById('searchFormShoes').style.display = "block";
                            document.getElementById('searchShoeSubmit').style.display = "block";
                        } else if (value === "any") {
                            document.getElementById('searchFormAny').style.display = "block";
                            document.getElementById('searchAnySubmit').style.display = "block";
                        }
                    });
                    }

                    // Create Auction Form Toggling
                    var itemsTypeSelect = document.getElementById('itemsTypeSelect');
                    if (itemsTypeSelect) {
                        itemsTypeSelect.addEventListener("change", function () {
                        const value = this.value;

                        if (value === "tops") {
                            document.getElementById('auctionFillOutFormTops').style.display = "block";
                            document.getElementById('auctionFillOutFormBottoms').style.display = "none";
                            document.getElementById('auctionFillOutFormShoes').style.display = "none";
                            document.getElementById('TopSubmit').style.display = "block";
                            document.getElementById('BottomSubmit').style.display = "none";
                            document.getElementById('ShoeSubmit').style.display = "none";
                        }
                        if (value === "bottoms") {
                            document.getElementById('auctionFillOutFormBottoms').style.display = "block";
                            document.getElementById('auctionFillOutFormTops').style.display = "none";
                            document.getElementById('auctionFillOutFormShoes').style.display = "none";
                            document.getElementById('BottomSubmit').style.display = "block";
                            document.getElementById('TopSubmit').style.display = "none";
                            document.getElementById('ShoeSubmit').style.display = "none";
                        }
                        if (value === "shoes") {
                            document.getElementById('auctionFillOutFormShoes').style.display = "block";
                            document.getElementById('auctionFillOutFormTops').style.display = "none";
                            document.getElementById('auctionFillOutFormBottoms').style.display = "none";
                            document.getElementById('ShoeSubmit').style.display = "block";
                            document.getElementById('TopSubmit').style.display = "none";
                            document.getElementById('BottomSubmit').style.display = "none";
                        }
                        });
                    }
                });
            </script>

                <!-- Search Section -->
                <div id="searchSection" class="search-section" style="display:none;">
                    <div class="card-header">
                        <h2 class="card-title">🔍 Search Items</h2>
                    </div>
                    <div class="form-group">
                        <label for="searchType">Choose Item Type to Search</label>
                        <select name="searchType" id="searchTypeSelect" class="form-control">
                    <option value="selectAnItem" disabled selected>Select Item...</option>
                    <option value="any">Any Item Type</option>
                    <option value="tops">Tops</option>
                    <option value="bottoms">Bottoms</option>
                    <option value="shoes">Shoes</option>
                </select>

                <!-- Any item type search form -->
                <form action="searchResults.jsp" method="POST">
                    <input type="hidden" name="itemType" value="any">
                    <div id="searchFormAny" class="form-row" style="display: none;">
                        <div class="form-group">
                            <label>Seller Username</label>
                            <input type="text" name="searchSeller" class="form-control" placeholder="Any seller">
                        </div>
                        <div class="form-group">
                            <label>Gender</label>
                            <select name="searchGender" class="form-control">
                            <option value="" selected>Any Gender</option>
                            <option value="Male">Male</option>
                            <option value="Female">Female</option>
                            <option value="Unisex">Unisex</option>
                        </select>
                        </div>
                        <div class="form-group">
                            <label>Size</label>
                            <input type="text" name="searchSize" class="form-control" placeholder="Any Size">
                        </div>
                        <div class="form-group">
                            <label>Color</label>
                            <select name="searchColor" class="form-control">
                            <option value="" selected>Any Color</option>
                            <option value="Black">Black</option>
                            <option value="Blue">Blue</option>
                            <option value="Gray">Gray</option>
                            <option value="White">White</option>
                            <option value="Brown">Brown</option>
                            <option value="Red">Red</option>
                            <option value="Pink">Pink</option>
                            <option value="Orange">Orange</option>
                            <option value="Yellow">Yellow</option>
                            <option value="Green">Green</option>
                            <option value="Purple">Purple</option>
                        </select>
                        </div>
                        <div class="form-group">
                            <label>Description contains</label>
                            <input type="text" name="searchDescription" class="form-control">
                        </div>
                        <div class="form-group">
                            <label>Condition</label>
                            <input type="text" name="searchCondition" class="form-control">
                        </div>
                        <div class="form-group">
                            <label>Min Price</label>
                            <input type="number" name="searchMinPrice" class="form-control" min="0" step="0.01">
                        </div>
                        <div class="form-group">
                            <label>Max Price</label>
                            <input type="number" name="searchMaxPrice" class="form-control" min="0" step="0.01">
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary" id="searchAnySubmit" style="display: none; width: 100%;">Search All Items</button>
                </form>

                <!-- Tops search form -->
                <form action="searchResults.jsp" method="POST">
                    <input type="hidden" name="itemType" value="tops">
                    <div id="searchFormTops" class="form-row" style="display: none;">
                        <div class="form-group">
                            <label>Seller Username</label>
                            <input type="text" name="searchSeller" class="form-control" placeholder="Any seller">
                        </div>
                        <div class="form-group">
                            <label>Gender</label>
                            <select name="searchTopGender" class="form-control">
                            <option value="" selected>Any Gender</option>
                            <option value="Male">Male</option>
                            <option value="Female">Female</option>
                            <option value="Unisex">Unisex</option>
                        </select>
                        </div>
                        <div class="form-group">
                            <label>Top Size</label>
                            <select name="searchTopSize" class="form-control">
                            <option value="" selected>Any Size</option>
                            <option value="XS">XS</option>
                            <option value="S">S</option>
                            <option value="M">M</option>
                            <option value="L">L</option>
                            <option value="XL">XL</option>
                            <option value="XXL">XXL</option>
                            <option value="3XL">3XL</option>
                        </select>
                        </div>
                        <div class="form-group">
                            <label>Color</label>
                            <select name="searchTopColor" class="form-control">
                            <option value="" selected>Any Color</option>
                            <option value="Black">Black</option>
                            <option value="Blue">Blue</option>
                            <option value="Gray">Gray</option>
                            <option value="White">White</option>
                            <option value="Brown">Brown</option>
                            <option value="Red">Red</option>
                            <option value="Pink">Pink</option>
                            <option value="Orange">Orange</option>
                            <option value="Yellow">Yellow</option>
                            <option value="Green">Green</option>
                            <option value="Purple">Purple</option>
                        </select>
                        </div>
                        <div class="form-group">
                            <label>Front Length (cm)</label>
                            <input type="number" name="searchTopFrontLength" class="form-control" min="0" step="0.1">
                        </div>
                        <div class="form-group">
                            <label>Chest Length (cm)</label>
                            <input type="number" name="searchTopChestLength" class="form-control" min="0" step="0.1">
                        </div>
                        <div class="form-group">
                            <label>Sleeve Length (cm)</label>
                            <input type="number" name="searchTopSleeveLength" class="form-control" min="0" step="0.1">
                        </div>
                        <div class="form-group">
                            <label>Description</label>
                            <input type="text" name="searchTopDescription" class="form-control">
                        </div>
                        <div class="form-group">
                            <label>Condition</label>
                            <input type="text" name="searchTopCondition" class="form-control">
                        </div>
                        <div class="form-group">
                            <label>Min Price</label>
                            <input type="number" name="searchMinPrice" class="form-control" min="0" step="0.01">
                        </div>
                        <div class="form-group">
                            <label>Max Price</label>
                            <input type="number" name="searchMaxPrice" class="form-control" min="0" step="0.01">
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary" id="searchTopSubmit" style="display: none; width: 100%;">Search Tops</button>
                </form>

                <!-- Bottoms search form -->
                <form action="searchResults.jsp" method="POST">
                    <input type="hidden" name="itemType" value="bottoms">
                    <div id="searchFormBottoms" style="display: none;">
                        <label>Seller Username:</label> <input type="text" name="searchSeller" placeholder="Any seller">
                        <label>Gender: </label>
                        <select name="searchBottomGender">
                            <option value="" selected>Any Gender</option>
                            <option value="Male">Male</option>
                            <option value="Female">Female</option>
                            <option value="Unisex">Unisex</option>
                        </select>
                        <label>Bottom Size: </label>
                        <select name="searchBottomSize">
                            <option value="" selected>Any Size</option>
                            <option value="XS">XS</option>
                            <option value="S">S</option>
                            <option value="M">M</option>
                            <option value="L">L</option>
                            <option value="XL">XL</option>
                            <option value="XXL">XXL</option>
                            <option value="3XL">3XL</option>
                        </select>
                        <label>Color: </label>
                        <select name="searchBottomColor">
                            <option value="" selected>Any Color</option>
                            <option value="Black">Black</option>
                            <option value="Blue">Blue</option>
                            <option value="Gray">Gray</option>
                            <option value="White">White</option>
                            <option value="Brown">Brown</option>
                            <option value="Red">Red</option>
                            <option value="Pink">Pink</option>
                            <option value="Orange">Orange</option>
                            <option value="Yellow">Yellow</option>
                            <option value="Green">Green</option>
                            <option value="Purple">Purple</option>
                        </select>
            <label>Waist Length (cm): </label> <input type="number" name="searchBottomWaistLength" min="0" step="0.1">
            <label>Inseam Length (cm): </label> <input type="number" name="searchBottomInseamLength" min="0" step="0.1">
            <label>Outseam Length (cm): </label> <input type="number" name="searchBottomOutseamLength" min="0" step="0.1">
            <label>Hip Length (cm): </label> <input type="number" name="searchBottomHipLength" min="0" step="0.1">
            <label>Rise Length (cm): </label> <input type="number" name="searchBottomRiseLength" min="0" step="0.1">
                        <label>Description: </label> <input type="text" name="searchBottomDescription">
                        <label>Condition: </label> <input type="text" name="searchBottomCondition">
                        <label>Min Price:</label> <input type="number" name="searchMinPrice" min="0">
                        <label>Max Price:</label> <input type="number" name="searchMaxPrice" min="0">
                    </div>
                    <button type="submit" class="btn btn-primary" id="searchBottomSubmit" style="display: none; width: 100%;">Search Bottoms</button>
                </form>

                <!-- Shoes search form -->
                <form action="searchResults.jsp" method="POST">
                    <input type="hidden" name="itemType" value="shoes">
                    <div id="searchFormShoes" class="form-row" style="display: none;">
                        <div class="form-group">
                            <label>Seller Username</label>
                            <input type="text" name="searchSeller" class="form-control" placeholder="Any seller">
                        </div>
                        <div class="form-group">
                            <label>Gender</label>
                            <select name="searchShoeGender" class="form-control">
                            <option value="" selected>Any Gender</option>
                            <option value="Male">Male</option>
                            <option value="Female">Female</option>
                            <option value="Unisex">Unisex</option>
                        </select>
                        </div>
                        <div class="form-group">
                            <label>Shoe Size</label>
                            <select name="searchShoeSize" class="form-control">
                            <option value="" selected>Any Size</option>
                            <% for (int i = 1; i <= 23; i++) { %>
                <option value="<%=i%>"><%=i%></option>
                                <% } %>
                        </select>
                        </div>
                        <div class="form-group">
                            <label>Color</label>
                            <select name="searchShoeColor" class="form-control">
                            <option value="" selected>Any Color</option>
                            <option value="Black">Black</option>
                            <option value="Blue">Blue</option>
                            <option value="Gray">Gray</option>
                            <option value="White">White</option>
                            <option value="Brown">Brown</option>
                            <option value="Red">Red</option>
                            <option value="Pink">Pink</option>
                            <option value="Orange">Orange</option>
                            <option value="Yellow">Yellow</option>
                            <option value="Green">Green</option>
                            <option value="Purple">Purple</option>
                        </select>
                        </div>
                        <div class="form-group">
                            <label>Description</label>
                            <input type="text" name="searchShoeDescription" class="form-control">
                        </div>
                        <div class="form-group">
                            <label>Condition</label>
                            <input type="text" name="searchShoeCondition" class="form-control">
                        </div>
                        <div class="form-group">
                            <label>Min Price</label>
                            <input type="number" name="searchMinPrice" class="form-control" min="0" step="0.01">
                        </div>
                        <div class="form-group">
                            <label>Max Price</label>
                            <input type="number" name="searchMaxPrice" class="form-control" min="0" step="0.01">
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary" id="searchShoeSubmit" style="display: none; width: 100%;">Search Shoes</button>
                </form>
            </div>

                <!-- Create Auction Modal -->
                <div id="createAuctionModal" class="modal" style="display: none;">
                    <div class="modal-content">
                        <span class="modal-close" onclick="closeAuctionModal()">&times;</span>
                        <div id="auctionFillOutForm" class="auction-form">
                    <div class="card-header">
                        <h2 class="card-title">➕ Create New Auction</h2>
                    </div>
                    <div class="form-group">
                        <label for="itemsType">Choose Item Type</label>
                        <select name="itemsType" id="itemsTypeSelect" class="form-control" required>
                    <option value="selectAnItem" disabled selected>Select Item...</option>
                    <option value="tops" id="tops">Tops</option>
                    <option value="bottoms" id="bottoms">Bottoms</option>
                    <option value="shoes" id="shoes">Shoes</option>
                </select>
            </div>

                <form action="../tops" method="POST" enctype="multipart/form-data">
                    <div id="auctionFillOutFormTops" class="form-row" style="display: none;">
                        <div class="form-group">
                            <label for="topGender">Gender</label>
                            <select name="topGender" id="topsGenderLabel" class="form-control" required>
                        <option value="SelectASize" disabled selected>Select Gender...</option>
                        <option value="Male">Male</option>
                        <option value="Female">Female</option>
                        <option value="Unisex">Unisex</option>
                    </select>
                        </div>
                        <div class="form-group">
                            <label for="topSize">Top Size</label>
                            <select name="topSize" id="topSizeSelect" class="form-control" required>
                        <option value="SelectASize" disabled selected>Select Size...</option>
                        <option value="XS">XS</option>
                        <option value="S">S</option>
                        <option value="M">M</option>
                        <option value="L">L</option>
                        <option value="XL">XL</option>
                        <option value="XXL">XXL</option>
                        <option value="3XL">3XL</option>
                    </select>
                        </div>
                        <div class="form-group">
                            <label for="topColor">Color</label>
                            <select name="topColor" id="TopColorColor" class="form-control" required>
                        <option value="SelectASize" disabled selected>Select Color...</option>
                        <option value="Black">Black</option>
                        <option value="Blue">Blue</option>
                        <option value="Gray">Gray</option>
                        <option value="White">White</option>
                        <option value="Brown">Brown</option>
                        <option value="Red">Red</option>
                        <option value="Pink">Pink</option>
                        <option value="Orange">Orange</option>
                        <option value="Yellow">Yellow</option>
                        <option value="Green">Green</option>
                        <option value="Purple">Purple</option>
                    </select>
                        </div>
                        <div class="form-group">
                            <label for="FrontLength">Front Length (cm)</label>
                            <input type="number" min="0" name="FrontLength" id="FrontLengthTop" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label for="ChestLength">Chest Length (cm)</label>
                            <input type="number" min="0" name="ChestLength" id="ChestLengthTop" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label for="SleeveLength">Sleeve Length (cm)</label>
                            <input type="number" min="0" name="SleeveLength" id="SleeveLengthTop" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label for="Description">Description</label>
                            <input name="Description" id="DescriptionTop" class="form-control" maxLength="200" required>
                        </div>
                        <div class="form-group">
                            <label for="Condition">Condition</label>
                            <input name="Condition" id="ConditionTop" class="form-control" maxLength="200" required>
                        </div>
                        <div class="form-group">
                            <label for="Minimum">Reserve Price (USD) - Hidden from buyers</label>
                            <input type="number" min="0" name="Minimum" id="MinimumBidConditionTop" class="form-control" step="0.01" required>
                        </div>
                        <div class="form-group">
                            <label for="StartingOrCurrentBidPrice">Starting Bid Price (USD)</label>
                            <input type="number" min="0" name="StartingOrCurrentBidPrice" id="StartingOrCurrentBidPriceTop" class="form-control" step="0.01" required>
                        </div>
                        <div class="form-group">
                            <label for="AuctionCloseDateTops">Auction Close Date</label>
                            <input type="date" name="AuctionCloseDateTops" id="AuctionCloseTopsDate" class="form-control" required min="<%=today%>">
                        </div>
                        <div class="form-group">
                            <label for="AuctionCloseTime">Auction Close Time</label>
                            <input type="time" name="AuctionCloseTimeTops" id="AuctionCloseTopsTime" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label for="image">Item Image (optional)</label>
                            <input type="file" name="image" id="imageTop" class="form-control" accept="image/*">
                        </div>
                </div>
                    <button type="submit" class="btn btn-primary" id="TopSubmit" style="display: none; width: 100%;">Create Auction</button>
            </form>

            <form action="bottoms.jsp" method="POST">
                    <div id="auctionFillOutFormBottoms" class="form-row" style="display: none;">
                        <div class="form-group">
                            <label for="bottomGender">Gender</label>
                            <select name="bottomGender" id="bottomGenderSelect" class="form-control" required>
                        <option value="SelectASize" disabled selected>Select Gender...</option>
                        <option value="Male">Male</option>
                        <option value="Female">Female</option>
                        <option value="Unisex">Unisex</option>
                    </select>
                        </div>
                        <div class="form-group">
                            <label for="bottomSize">Bottom Size</label>
                            <select name="bottomSize" id="bottomSizeSelect" class="form-control" required>
                        <option value="SelectASize" disabled selected>Select Size...</option>
                        <option value="XS">XS</option>
                        <option value="S">S</option>
                        <option value="M">M</option>
                        <option value="L">L</option>
                        <option value="XL">XL</option>
                        <option value="XXL">XXL</option>
                        <option value="3XL">3XL</option>
                    </select>
                        </div>
                        <div class="form-group">
                            <label for="bottomColor">Color</label>
                            <select name="bottomColor" id="bottomColorColor" class="form-control" required>
                        <option value="SelectASize" disabled selected>Select Color...</option>
                        <option value="Black">Black</option>
                        <option value="Blue">Blue</option>
                        <option value="Gray">Gray</option>
                        <option value="White">White</option>
                        <option value="Brown">Brown</option>
                        <option value="Red">Red</option>
                        <option value="Pink">Pink</option>
                        <option value="Orange">Orange</option>
                        <option value="Yellow">Yellow</option>
                        <option value="Green">Green</option>
                        <option value="Purple">Purple</option>
                    </select>
                        </div>
                        <div class="form-group">
                            <label for="WaistLength">Waist Length (cm)</label>
                            <input type="number" min="0" name="WaistLength" id="WaistLengthBottom" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label for="InseamLength">Inseam Length (cm)</label>
                            <input type="number" min="0" name="InseamLength" id="InseamLengthBottom" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label for="OutseamLength">Outseam Length (cm)</label>
                            <input type="number" min="0" name="OutseamLength" id="OutseamLengthBottom" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label for="HipLength">Hip Length (cm)</label>
                            <input type="number" min="0" name="HipLength" id="HipLengthBottom" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label for="RiseLength">Rise Length (cm)</label>
                            <input type="number" min="0" name="RiseLength" id="RiseLengthBottom" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label for="Description">Description</label>
                            <input name="Description" id="DescriptionBottom" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label for="Condition">Condition</label>
                            <input name="Condition" id="ConditionBottom" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label for="Minimum">Reserve Price (USD) - Hidden from buyers</label>
                            <input type="number" min="0" name="Minimum" id="MinimumBidConditionBottom" class="form-control" step="0.01">
                        </div>
                        <div class="form-group">
                            <label for="AuctionCloseDateBottoms">Auction Close Date</label>
                            <input type="date" name="AuctionCloseDateBottoms" id="AuctionCloseBottomsDate" class="form-control" min="<%=today%>">
                        </div>
                        <div class="form-group">
                            <label for="AuctionCloseTimeBottoms">Auction Close Time</label>
                            <input type="time" name="AuctionCloseTimeBottoms" id="AuctionCloseBottomsTime" class="form-control">
                        </div>
                </div>
                    <button type="submit" class="btn btn-primary" id="BottomSubmit" style="display: none; width: 100%;">Create Auction</button>
            </form>

            <form action="shoes.jsp" method="POST">
                    <div id="auctionFillOutFormShoes" class="form-row" style="display: none;">
                        <div class="form-group">
                            <label for="shoeGender">Gender</label>
                            <select name="shoeGender" id="shoeGenderSelect" class="form-control" required>
                        <option value="SelectASize" disabled selected>Select Gender...</option>
                        <option value="Male">Male</option>
                        <option value="Female">Female</option>
                        <option value="Unisex">Unisex</option>
                    </select>
                        </div>
                        <div class="form-group">
                            <label for="shoeSize">Shoe Size</label>
                            <select name="shoeSize" id="shoeSizeSelect" class="form-control" required>
                        <option value="SelectASize" disabled selected>Select Size...</option>
                                <% for (int i = 1; i <= 23; i++) { %>
                                <option value="<%=i%>"><%=i%></option>
                                <% } %>
                    </select>
                        </div>
                        <div class="form-group">
                            <label for="shoeColor">Color</label>
                            <select name="shoeColor" id="ShoeColorColor" class="form-control" required>
                        <option value="SelectASize" disabled selected>Select Color...</option>
                        <option value="Black">Black</option>
                        <option value="Blue">Blue</option>
                        <option value="Gray">Gray</option>
                        <option value="White">White</option>
                        <option value="Brown">Brown</option>
                        <option value="Red">Red</option>
                        <option value="Pink">Pink</option>
                        <option value="Orange">Orange</option>
                        <option value="Yellow">Yellow</option>
                        <option value="Green">Green</option>
                        <option value="Purple">Purple</option>
                    </select>
                        </div>
                        <div class="form-group">
                            <label for="Description">Description</label>
                            <input maxlength="200" name="Description" id="DescriptionShoe" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label for="Condition">Condition</label>
                            <input maxlength="200" name="Condition" id="ConditionShoe" class="form-control" required>
                        </div>
                        <div class="form-group">
                            <label for="Minimum">Reserve Price (USD) - Hidden from buyers</label>
                            <input type="number" min="0" name="Minimum" id="MinimumBidConditionShoe" class="form-control" step="0.01">
                        </div>
                        <div class="form-group">
                            <label for="AuctionCloseDateShoes">Auction Close Date</label>
                            <input type="date" name="AuctionCloseDateShoes" id="AuctionCloseShoesDate" class="form-control" min="<%=today%>">
                        </div>
                        <div class="form-group">
                            <label for="AuctionCloseTimeShoes">Auction Close Time</label>
                            <input type="time" name="AuctionCloseTimeShoes" id="AuctionCloseShoesTime" class="form-control">
                        </div>
                    </div>
                    <button type="submit" class="btn btn-primary" id="ShoeSubmit" style="display: none; width: 100%;">Create Auction</button>
                </form>
                        </div>
                    </div>
                </div>

            </div>
        </div>

        </body>
        </html>