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
            <title>Main Page</title>
        </head>

        <body>
<h3>User: <%=session.getAttribute("username")%></h3>
            <h1>Welcome to Thrift Shop</h1>

            <nav>
                <ul>
                    <li><a href="tops.jsp">Tops</a></li>
                    <li><a href="bottoms.jsp">Bottoms</a></li>
                    <li><a href="shoes.jsp">Shoes</a></li>
                    <li><a href="sellers.jsp">Sellers</a></li>
                    <li><a href="notifications.jsp">Notifications</a></li>
                    <li><a href="profile.jsp">Profile</a></li>
                </ul>
            </nav>

        </body>

        <body>
            <script>

                document.addEventListener("DOMContentLoaded", function () {
                    // Search Form Toggling
                    document.getElementById('searchTypeSelect').addEventListener("change", function () {
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

                    // Create Auction Form Toggling
                    document.getElementById('itemsTypeSelect').addEventListener("change", function () {
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
                    })
                });

                function createAuction() {
                    document.getElementById('auctionFillOutForm').style.display = "block";
                }

                function toggleSearch() {
                    var searchDiv = document.getElementById('searchSection');
                    if (searchDiv.style.display === "none") {
                        searchDiv.style.display = "block";
                    } else {
                        searchDiv.style.display = "none";
                    }
                }
            </script>

            <button onclick='toggleSearch()'>Search Items</button>
            <div id="searchSection" style="display:none; border: 1px solid black; padding: 10px; margin-bottom: 20px;">
                <h3>Search Items</h3>
                <label for="searchType">Choose Item Type to Search: </label>
                <select name="searchType" id="searchTypeSelect">
                    <option value="selectAnItem" disabled selected>Select Item...</option>
                    <option value="any">Any Item Type</option>
                    <option value="tops">Tops</option>
                    <option value="bottoms">Bottoms</option>
                    <option value="shoes">Shoes</option>
                </select>

                <!-- Any item type search form -->
                <form action="searchResults.jsp" method="POST">
                    <input type="hidden" name="itemType" value="any">
                    <div id="searchFormAny" style="display: none;">
                        <p>Search across Tops, Bottoms and Shoes</p>
                        <label>Seller Username:</label> <input type="text" name="searchSeller" placeholder="Any seller">
                        <label>Gender: </label>
                        <select name="searchGender">
                            <option value="" selected>Any Gender</option>
                            <option value="Male">Male</option>
                            <option value="Female">Female</option>
                            <option value="Unisex">Unisex</option>
                        </select>
                        <label>Size:</label>
                        <input type="text" name="searchSize" placeholder="Any Size">
                        <label>Color: </label>
                        <select name="searchColor">
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
                        <label>Description contains: </label> <input type="text" name="searchDescription">
                        <label>Condition: </label> <input type="text" name="searchCondition">
                        <label>Min Price:</label> <input type="number" name="searchMinPrice" min="0">
                        <label>Max Price:</label> <input type="number" name="searchMaxPrice" min="0">
                    </div>
                    <input type="submit" value="Search All Items" id="searchAnySubmit" style="display: none;" />
                </form>

                <!-- Tops search form -->
                <form action="searchResults.jsp" method="POST">
                    <input type="hidden" name="itemType" value="tops">
                    <div id="searchFormTops" style="display: none;">
                        <label>Seller Username:</label> <input type="text" name="searchSeller" placeholder="Any seller">
                        <label>Gender: </label>
                        <select name="searchTopGender">
                            <option value="" selected>Any Gender</option>
                            <option value="Male">Male</option>
                            <option value="Female">Female</option>
                            <option value="Unisex">Unisex</option>
                        </select>
                        <label>Top Size:</label>
                        <select name="searchTopSize">
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
                        <select name="searchTopColor">
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
            <label>Front Length (cm): </label> <input type="number" name="searchTopFrontLength" min="0" step="0.1">
            <label>Chest Length (cm): </label> <input type="number" name="searchTopChestLength" min="0" step="0.1">
            <label>Sleeve Length (cm): </label> <input type="number" name="searchTopSleeveLength" min="0" step="0.1">
                        <label>Description: </label> <input type="text" name="searchTopDescription">
                        <label>Condition: </label> <input type="text" name="searchTopCondition">
                        <label>Min Price:</label> <input type="number" name="searchMinPrice" min="0">
                        <label>Max Price:</label> <input type="number" name="searchMaxPrice" min="0">

                    </div>
                    <input type="submit" value="Search Tops" id="searchTopSubmit" style="display: none;" />
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
                    <input type="submit" value="Search Bottoms" id="searchBottomSubmit" style="display: none;" />
                </form>

                <!-- Shoes search form -->
                <form action="searchResults.jsp" method="POST">
                    <input type="hidden" name="itemType" value="shoes">
                    <div id="searchFormShoes" style="display: none;">
                        <label>Seller Username:</label> <input type="text" name="searchSeller" placeholder="Any seller">
                        <label>Gender: </label>
                        <select name="searchShoeGender">
                            <option value="" selected>Any Gender</option>
                            <option value="Male">Male</option>
                            <option value="Female">Female</option>
                            <option value="Unisex">Unisex</option>
                        </select>
                        <label>Shoe Size: </label>
                        <select name="searchShoeSize">
                            <option value="" selected>Any Size</option>
                            <% for (int i = 1; i <= 23; i++) { %>
                <option value="<%=i%>"><%=i%></option>
                                <% } %>
                        </select>
                        <label>Color: </label>
                        <select name="searchShoeColor">
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
                        <label>Description: </label> <input type="text" name="searchShoeDescription">
                        <label>Condition: </label> <input type="text" name="searchShoeCondition">
                        <label>Min Price:</label> <input type="number" name="searchMinPrice" min="0">
                        <label>Max Price:</label> <input type="number" name="searchMaxPrice" min="0">
                    </div>
                    <input type="submit" value="Search Shoes" id="searchShoeSubmit" style="display: none;" />
                </form>
            </div>

            <div id="auctionFillOutForm" style="display: none;">
                <label for="itemsType">Choose Item Type: </label>
                <select name="itemsType" id="itemsTypeSelect" required>
                    <option value="selectAnItem" disabled selected>Select Item...</option>
                    <option value="tops" id="tops">Tops</option>
                    <option value="bottoms" id="bottoms">Bottoms</option>
                    <option value="shoes" id="shoes">Shoes</option>
                </select>
            </div>

            <form action="tops.jsp" method="POST">
                <div id="auctionFillOutFormTops" style="display: none;">
                    <label for="topGender">Gender: </label>
                    <select name="topGender" id="topsGenderLabel" required>
                        <option value="SelectASize" disabled selected>Select Gender...</option>
                        <option value="Male">Male</option>
                        <option value="Female">Female</option>
                        <option value="Unisex">Unisex</option>
                    </select>
                    <label for="topSize">Top Size:</label>
                    <select name="topSize" id="topSizeSelect" required>
                        <option value="SelectASize" disabled selected>Select Size...</option>
                        <option value="XS">XS</option>
                        <option value="S">S</option>
                        <option value="M">M</option>
                        <option value="L">L</option>
                        <option value="XL">XL</option>
                        <option value="XXL">XXL</option>
                        <option value="3XL">3XL</option>
                    </select>
                    <label for="topColor">Color: </label>
                    <select name="topColor" id="TopColorColor" required>
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
                    <label for="FrontLength">Front Length (cm): </label>
                    <input type="number" min="0" name="FrontLength" id="FrontLengthTop" required>
                    <label for="ChestLength">Chest Length (cm): </label>
                    <input type="number" min="0" name="ChestLength" id="ChestLengthTop" required>
                    <label for="SleeveLength">Sleeve Length (cm): </label>
                    <input type="number" min="0" name="SleeveLength" id="SleeveLengthTop" required>
                    <label for="Description">Description: </label>
                    <input name="Description" id="DescriptionTop" maxLength="200" required>
                    <label for="Condition">Condition: </label>
                    <input name="Condition" id="ConditionTop" maxLength="200" required>
                    <label for="Minimum">Minimum Bid Price (USD): </label>
                    <input type="number" min="0" name="Minimum" id="MinimumBidConditionTop" required>
                    <label for="StartingOrCurrentBidPrice">Starting Bid Price(USD): </label>
                    <input type="number" min="0" name="StartingOrCurrentBidPrice" id="StartingOrCurrentBidPriceTop" required>
                    <label for="AuctionCloseDateTops">Auction Close Date: </label>
                    <input type="date" name="AuctionCloseDateTops" id="AuctionCloseTopsDate" required min="<%=today%>">
                    <label for="AuctionCloseTime">Auction Close Time: </label>
                    <input type="time" name="AuctionCloseTimeTops" id="AuctionCloseTopsTime" required>
                </div>
                <input type="submit" value="Submit" id="TopSubmit" style="display: none;" />
            </form>

            <form action="bottoms.jsp" method="POST">
                <div id="auctionFillOutFormBottoms" style="display: none;">
                    <label for="bottomGender">Gender: </label>
                    <select name="bottomGender" id="bottomGenderSelect" required>
                        <option value="SelectASize" disabled selected>Select Gender...</option>
                        <option value="Male">Male</option>
                        <option value="Female">Female</option>
                        <option value="Unisex">Unisex</option>
                    </select>
                    <label for="bottomSize">Bottom Size: </label>
                    <select name="bottomSize" id="bottomSizeSelect" required>
                        <option value="SelectASize" disabled selected>Select Size...</option>
                        <option value="XS">XS</option>
                        <option value="S">S</option>
                        <option value="M">M</option>
                        <option value="L">L</option>
                        <option value="XL">XL</option>
                        <option value="XXL">XXL</option>
                        <option value="3XL">3XL</option>
                    </select>
                    <label for="bottomColor">Color: </label>
                    <select name="bottomColor" id="bottomColorColor" required>
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
                    <label for="WaistLength">Waist Length (cm): </label>
                    <input type="number" min="0" name="WaistLength" id="WaistLengthBottom" required>
                    <label for="InseamLength">Inseam Length (cm): </label>
                    <input type="number" min="0" name="InseamLength" id="InseamLengthBottom" required>
                    <label for="OutseamLength">Outseam Length (cm): </label>
                    <input type="number" min="0" name="OutseamLength" id="OutseamLengthBottom" required>
                    <label for="HipLength">Hip Length (cm): </label>
                    <input type="number" min="0" name="HipLength" id="HipLengthBottom" required>
                    <label for="RiseLength">Rise Length (cm): </label>
                    <input type="number" min="0" name="RiseLength" id="RiseLengthBottom" required>
                    <label for="Description">Description: </label>
                    <input name="Description" id="DescriptionBottom" required>
                    <label for="Condition">Condition: </label>
                    <input name="Condition" id="ConditionBottom" required>
                    <label for="Minimum">Minimum Bid Price (USD): </label>
                    <input type="number" min="0" name="Minimum" id="MinimumBidConditionBottom">
                    <label for="AuctionCloseDateBottoms">Auction Close Date: </label>
                    <input type="date" name="AuctionCloseDateBottoms" id="AuctionCloseBottomsDate" min="<%=today%>">
                    <label for="AuctionCloseTimeBottoms">Auction Close Time: </label>
                    <input type="time" name="AuctionCloseTimeBottoms" id="AuctionCloseBottomsTime">
                </div>
                <input type="submit" value="Submit" id="BottomSubmit" style="display: none;" />
            </form>

            <form action="shoes.jsp" method="POST">
                <div id="auctionFillOutFormShoes" style="display: none;">
                    <label for="shoeGender">Gender: </label>
                    <select name="shoeGender" id="shoeGenderSelect" required>
                        <option value="SelectASize" disabled selected>Select Gender...</option>
                        <option value="Male">Male</option>
                        <option value="Female">Female</option>
                        <option value="Unisex">Unisex</option>
                    </select>
                    <label for="shoeSize">Shoe Size: </label>
                    <select name="shoeSize" id="shoeSizeSelect" required>
                        <option value="SelectASize" disabled selected>Select Size...</option>
                        <option value="1">1</option>
                        <option value="2">2</option>
                        <option value="3">3</option>
                        <option value="4">4</option>
                        <option value="5">5</option>
                        <option value="6">6</option>
                        <option value="7">7</option>
                        <option value="8">8</option>
                        <option value="9">9</option>
                        <option value="10">10</option>
                        <option value="11">11</option>
                        <option value="12">12</option>
                        <option value="13">13</option>
                        <option value="14">14</option>
                        <option value="15">15</option>
                        <option value="16">16</option>
                        <option value="17">17</option>
                        <option value="18">18</option>
                        <option value="19">19</option>
                        <option value="20">20</option>
                        <option value="21">21</option>
                        <option value="22">22</option>
                        <option value="23">23</option>
                    </select>
                    <label for="shoeColor">Color: </label>
                    <select type="color" name="shoeColor" id="ShoeColorColor" required>
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
                    <label for="Description">Description: </label>
                    <input maxlength="200" name="Description" id="DescriptionShoe" required>
                    <label for="Condition">Condition: </label>
                    <input maxlength="200" name="Condition" id="ConditionShoe" required>
                    <label for="Minimum">Minimum Bid Price (USD): </label>
                    <input type="number" min="0" name="Minimum" id="MinimumBidConditionShoe">
                    <label for="AuctionCloseDateShoes">Auction Close Date: </label>
                    <input type="date" name="AuctionCloseDateShoes" id="AuctionCloseShoesDate" min="<%=today%>">
                    <label for="AuctionCloseTimeShoes">Auction Close Time: </label>
                    <input type="time" name="AuctionCloseTimeShoes" id="AuctionCloseShoesDate">
                </div>
                <input type="submit" value="Submit" id="ShoeSubmit" style="display: none;" />
            </form>

            <button onclick='createAuction()'>create auction</button>
        </body>

        </html>